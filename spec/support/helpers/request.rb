module Helpers
  module Request
    def json_headers
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    def form_headers
      {
        'Content-Type' => 'multipart/form-data',
        'Accept' => 'application/json'
      }
    end

    def post_json(url, params: {}, headers: {})
      post url, params: params.to_json, headers: json_headers.merge(headers)
    end

    def put_json(url, params: {}, headers: {})
      put url, params: params.to_json, headers: json_headers.merge(headers)
    end

    def del_json(url, headers: {})
      delete url, headers: json_headers.merge(headers)
    end

    def json
      JSON.parse(response.body)
    end
  end
end
