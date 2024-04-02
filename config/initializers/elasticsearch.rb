# frozen_string_literal: true
Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: 'https://127.0.0.1:9200',
  request_timeout: 30
) do |f|
  f.ssl[:verify] = false
end

# Prevents this message from appearing in logs:
#   You are setting a key that conflicts with a built-in method Hashie::Mash#key defined in Hash.
#   This can cause unexpected behavior when accessing the key via as a property.
#   You can still access the key via the #[] method.
Hashie.logger = Logger.new(nil)
