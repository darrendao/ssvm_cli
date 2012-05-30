module CookieJar
  def get_cookies
    params = {:login => @username, :password => @password}
    cookies = nil
    RestClient.post("https://#{@server}/login/login", params) do |response, request, result, &block|
      if response.code == 200
        cookies = response.cookies      
      elsif response.code == 302 && response.headers[:location] !~ /login/
        cookies = response.cookies      
      else
        raise "Failed to authenticate"
      end
    end 
    cookies
  end
end
