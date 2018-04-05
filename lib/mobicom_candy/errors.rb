module MobicomCandy
  class Error < StandardError
  end
  class ClientError < Error
  end
  class AuthenticationError < ClientError
  end
  class ServerError < Error
  end
end
