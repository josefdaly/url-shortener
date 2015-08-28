require_relative './route'

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(http_method, pattern, controller_class, action_name)
    routes << Route.new(http_method, pattern, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(http_method, pattern, controller_class, action_name)
    end
  end

  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    # Find the route
    route = match(req)

    # Run the route if found, 404 otherwise
    route ? route.run(req, res) : res.status = 404
  end
end
