class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(http_method, pattern, controller_class, action_name)
    @http_method, @pattern = http_method, pattern
    @controller_class, @action_name = controller_class, action_name
  end

  def matches?(req)
    req.request_method.downcase.to_sym == http_method && pattern.match(req.path)
  end

  def run(req, res)
    route_params = {}

    # pattern is a Regexp object. Regexp.match returns a MatchData object.
    path_vars = pattern.match(req.path)
    path_vars.names.each { |name| route_params[name.to_sym] = path_vars[name] }

    controller_class.new(req, res, route_params).invoke_action(action_name)
  end
end
