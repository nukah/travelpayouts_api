module TravelPayouts
  class Error < Exception
    attr_accessor :response

    def code
      return unless response
      response.code
    end
  end
end
