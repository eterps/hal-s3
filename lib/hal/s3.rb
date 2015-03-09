require 'hal/s3/version'
require 'uri'
require 'aws-sdk'

module HAL
  module S3
    class DirectoryIndex
      attr_reader :relation_name, :self_url, :uri

      def initialize(uri, relation_name: 'items', self_url: nil)
        @uri           = URI(uri)
        @relation_name = relation_name
        @self_url      = self_url

        options = {}
        options[:endpoint] = "https://s3-#{ENV['AWS_REGION']}.amazonaws.com" if ENV['AWS_REGION']
        @s3 = Aws::S3::Client.new(options)
      end

      def to_hash
        data = {
          '_links' => {'self' => {'href' => self_url}}
        }
        data['_links'][relation_name] = hrefs
        data
      end

      def to_json(pretty: false)
        pretty ? JSON.pretty_unparse(to_hash) : to_hash.to_json
      end

      private

      def list(delimiter: '/', prefix: nil)
        @s3.list_objects(bucket: uri.host, delimiter: delimiter, prefix: prefix).common_prefixes.map(&:prefix)
      end

      def paths
        head, tail = uri.path.split('*').map{|n| n[1..-1]}

        collections = list(prefix: head)
        collections.map do |c|
          list(delimiter: tail, prefix: c).first
        end.compact
      end

      def hrefs
        paths.map do |path|
          {href: "https://#{uri.host}/#{path}"}
        end
      end
    end
  end
end
