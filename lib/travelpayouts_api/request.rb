module TravelPayouts
  class Api
    module Request
      def request(url, params, skip_parse: false)
        params[:currency] ||= config.currency
        params[:locale]   ||= config.locale

        params.delete_if{ |_, v| v == nil }

        response = run_get(url, params, request_headers)
        data = response.to_s

        skip_parse ? data : respond(data)
      end

      def signed_flight_request(method, url, params)
        params[:host]     = config.host
        params[:currency] ||= config.currency
        params[:locale]   ||= config.locale if params.has_key?(:locale)

        params.delete_if{ |_, v| v == nil }

        params[:signature] = signature(params)
        params[:marker]   = config.marker.to_s

        run_request(url, params, request_headers(true), method)
      end

      def signed_hotel_request(method, url, params)
        params[:marker]   = config.marker.to_s
        params[:currency] ||= config.currency
        params[:lang]     ||= config.locale if params.has_key?(:lang)

        params.delete_if{ |_, v| v == nil }

        params[:signature] = signature(params, config.marker)

        run_request(url, params, request_headers(true), method)
      end

      def sort_params(params)
        return params unless params.is_a?(Hash) || params.is_a?(Array)
        return Hash[params.sort.map{ |k,v| [k, sort_params(v)] }] if params.is_a?(Hash)
        params.map {|p| sort_params(p)}
      end

      def param_values(params)
        return params unless params.is_a?(Hash) || params.is_a?(Array)
        return params.values.map{|v| param_values(v)}.flatten if params.is_a?(Hash)
        params.map {|p| param_values(p)}.flatten
      end

      def signature(params, marker=nil)
        sign = marker ? [config.token, marker] : [config.token]
        values = sign + param_values(sort_params(params))
        Digest::MD5.hexdigest values.join(':')
      end

      def request_headers(include_content_type = false)
        {
          x_access_token: config.token,
          accept_encoding: 'gzip, deflate',
          accept: :json
        }.tap do |headers|
          headers[:content_type] = 'application/json' if include_content_type
        end
      end

      def respond(resp)
        begin
          hash = Oj.load(resp)
        rescue => _
          return resp
        end
      end

      def persistent(url)
        uri = URI.parse(url)
        HTTP.persistent("http://#{uri.host}") do |connection|
          yield(connection, uri.path)
        end
      end

      def run_post(url, params, headers)
        begin
          response = persistent(url) do |http, path|
            http.headers(headers).post(path, form: params).flush
          end
          err = Error.new('Server returned 500 error!')
          err.response = response
          raise err if response.code == 500
          response.to_s
        rescue HTTP::Error => e
          raise Error.new(e.message)
        end
      end

      def run_get(url, params, headers)
        begin
          response = persistent(url) do |http, path|
            http.headers(headers).get(path, params: params).flush
          end
          err = Error.new('Server returned 500 error!')
          err.response = response
          raise err if response.code == 500
          response.to_s
        rescue HTTP::Error => e
          raise Error.new(e.message)
        end
      end

      def run_request(url, params, headers, method)
        if method == :post
          run_post(url, params, headers)
        else
          run_get(url, params, headers)
        end
      end
    end
  end
end
