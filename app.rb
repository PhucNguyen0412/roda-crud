require_relative 'models'

require 'roda'
require 'tilt/sass'

class MyApp < Roda
  plugin :default_headers,
    'Content-Type'=>'text/html',
    #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self, 'https://maxcdn.bootstrapcdn.com'
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  plugin :route_csrf
  plugin :flash
  plugin :assets, css: 'app.scss', css_opts: {style: :compressed, cache: false}, timestamp_paths: true
  plugin :render, escape: true
  plugin :public
  plugin :multi_route

  logger = if ENV['RACK_ENV'] == 'test'
    Class.new{def write(_) end}.new
  else
    $stderr
  end
  plugin :common_logger, logger

  plugin :not_found do
    @page_title = "File Not Found"
    view(:content=>"")
  end

  if ENV['RACK_ENV'] == 'development'
    plugin :exception_page
    class RodaRequest
      def assets
        exception_page_assets
        super
      end
    end
  end

  plugin :error_handler do |e|
    case e
    when Roda::RodaPlugins::RouteCsrf::InvalidToken
      @page_title = "Invalid Security Token"
      response.status = 400
      view(:content=>"<p>An invalid security token was submitted with this request, and this request could not be processed.</p>")
    else
      $stderr.print "#{e.class}: #{e.message}\n"
      $stderr.puts e.backtrace
      next exception_page(e, :assets=>true) if ENV['RACK_ENV'] == 'development'
      @page_title = "Internal Server Error"
      view(:content=>"")
    end
  end

  plugin :sessions,
    key: '_MyApp.session',
    #cookie_options: {secure: ENV['RACK_ENV'] != 'test'}, # Uncomment if only allowing https:// access
    secret: ENV.send((ENV['RACK_ENV'] == 'development' ? :[] : :delete), 'MY_APP_SESSION_SECRET')

  Unreloader.require('routes'){}

  plugin :json, classes: [Array, Hash, Sequel::Model]
  plugin :json_parser
  plugin :all_verbs
  plugin :halt

  route do |r|
    r.public
    r.assets
    check_csrf!
    r.multi_route

    r.root do
      view 'index'
    end

    r.is 'books' do
      r.get do
        page = r.params[:page] || 1
        { books: Book.paginate(page, 20).map(&:to_json) }
      end

      r.post do
        @book = Book.create(book_params(r))
        { book: @book.to_json }
      end
    end

    r.is 'book', Integer do |book_id|
      # book/:id used to match get, put and delete request, to provide
      # getting book by id, updating and deleting book
      @book = Book[book_id]
      # use halt to return 404 without evaluating rest of the block
      r.halt(404) unless @book

      r.get do
        { book: @book.to_json }
      end

      r.put do
        @book.update(book_params(r))
        { book: @book.to_json }
      end

      r.delete do
        @book.destroy
        response.status = 204
        {}
      end
    end
  end

  private

  def book_params(r)
    { release_year: r.params['release_year'], image_data: r.params['image_data'], title: r.params['title'] }
  end
end
