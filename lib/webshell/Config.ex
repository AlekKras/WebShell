defmodule WebShell.Config do
  # WebShell_SINK_PORT
  #
  # TCP port for WebShell to listen to incoming pipe connections
  def sink_port do
    get_env("WebShell_SINK_PORT", "1337")
    |> String.to_integer
  end

  # WebShell_BIND
  #
  # Address for WebShell to bind to. For example, binding to 127.0.0.1
  # will cause WebShell to reject all traffic from outside the local
  # machine, while binding to 0.0.0.0 will allow traffic from
  # anywhere.
  def sink_bind do
    get_env("WebShell_BIND", "0.0.0.0")
  end

  # WebShell_WEB_PORT
  #
  # Port for WebShell to start its web server on.
  def web_port do
    get_env("WebShell_WEB_PORT", "8090")
    |> String.to_integer
  end

  # WebShell_HOST
  #
  # Hostname of the WebShell server. Used to report to clients where
  # they can view their pipes
  def host do
    get_env("WebShell_HOST", "localhost")
  end

  # WebShell_DIR
  #
  # Directory to store logs in
  def log_dir do
    get_env("WebShell_DIR", "/tmp/WebShell")
  end

  # WebShell_URL
  #
  # Base URL from which the WebShell server is accessible from the
  # outside world. Default is sane unless WebShell is running behind
  # nginx or another similar reverse proxy.
  def base_url do
    get_env("WebShell_URL", "http://#{host()}:#{web_port()}")
  end

  # WebShell_MAX_SIZE
  #
  # Maximum size of each pipe. Defaults to effectively unlimited
  # (999TB), Use T, G, M, K suffixes to avoid doing math.
  def max_file do
    # lol, this is bad.
    {byte_size, _} = get_env("WebShell_MAX_SIZE", "999 T")
    |> String.downcase
    |> String.replace("t", " * 1024 g")
    |> String.replace("g", " * 1024 m")
    |> String.replace("m", " * 1024 k")
    |> String.replace("k", " * 1024")
    |> Code.eval_string

    byte_size
  end

  # WebShell_PIPE_EXPIRATION
  #
  # If set, inactive pipe log files will be deleted after specified
  # duration. If left unset, log files will never expire and must be
  # rotated by some other process.
  #
  # Duration is in seconds, using "d" (day), "h" (hour), "m" (minute)
  # as suffixes for convenience (e.g. "3600" == "60m" == "1h")
  def pipe_expiration do
    if duration = System.get_env("WebShell_PIPE_EXPIRATION") do
      {duration, _} =
        duration
        |> String.downcase
        |> String.replace("d", "* 24 h")
        |> String.replace("h", "* 60 m")
        |> String.replace("m", "* 60")
        |> Code.eval_string

      duration * 1000
    end
  end

  # WebShell_SHOW_LISTING
  #
  # When set to "true", expose the /pipes web endpoint to display a
  # list of active and inactive pipes this server has seen. If this
  # WebShell isn't exposed to the internet, it's probably what you'd
  # want. Set to "false" or leave unset to disable.
  def show_listing do
    case get_env("WebShell_SHOW_LISTING", "false") do
      "true" -> true
      "false" -> false
      _ -> raise ArgumentError, message: "invalid WebShell_SHOW_LISTING \
value, expected true/false"
    end
  end

  defp get_env(key, default) do
    System.get_env(key) || default
  end

end
