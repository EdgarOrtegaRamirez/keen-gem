module Keen
  class Client
    module QueryingMethods

      # Runs a count query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#count-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def count(event_collection, params={})
        query(__method__, event_collection, params)
      end

      # Runs a count unique query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#count-unique-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def count_unique(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a minimum query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#minimum-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def minimum(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a maximum query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#maximum-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def maximum(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a sum query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#sum-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def sum(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a average query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#average-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def average(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a median query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#median-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def median(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a percentile query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#percentile-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   percentile (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def percentile(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a select_unique query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#select-unique-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def select_unique(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Runs a extraction query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#extraction-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   target_property (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      #   latest (optional)
      def extraction(event_collection, params={})
        query(__method__, event_collection, params)
      end

      # Runs a funnel query.
      # See detailed documentation here:
      # https://keen.io/docs/api/reference/#funnel-resource
      #
      # @param event_collection
      # @param params [Hash] (optional)
      #   steps (required)
      def funnel(params)
        query(__method__, nil, params)
      end

      # Runs a multi-analysis query
      # See detailed documentation here:
      # https://keen.io/docs/data-analysis/multi-analysis/
      #
      # NOTE: why isn't multi-analysis listed in the
      #       API Technical Reference?
      #
      # @param event_collection
      # @param params [Hash]
      #   analyses [Hash] (required)
      #     label (required)
      #     analysis_type (required)
      #     target_property (optional)
      def multi_analysis(event_collection, params)
        query(__method__, event_collection, params)
      end

      # Returns the URL for a Query without running it
      # @param event_colection
      # @param params [Hash] (required)
      #   analysis_type (required)
      #   group_by (optional)
      #   timeframe (optional)
      #   interval (optional)
      #   filters (optional) [Array]
      #   timezone (optional)
      def query_url(event_collection, params)
        ensure_project_id!
        query_name = params.delete(:analysis_type)
        params[:event_collection] = event_collection.to_s if event_collection
        "#{self.api_url}#{api_query_resource_path(query_name)}?#{preprocess_params(params)}"
      end

      private

      def query(query_name, event_collection, params)
        ensure_read_key!
        query_params = (params.dup || {}).merge({:analysis_type => query_name})
        url = query_url(event_collection, query_params)
        response = get_response(url)
        response_body = response.body.chomp
        process_response(response.code, response_body)["result"]
      end

      def get_response(url)
        uri = URI.parse(url)
        http_sync.get(
          :path => "#{uri.path}?#{uri.query}",
          :headers => headers
        )
      rescue Exception => http_error
        raise HttpError.new("Couldn't perform #{@analysis_type} on Keen IO: #{http_error.message}", http_error)
      end

      def http_sync
        Keen::HTTP::Sync.new(self.api_url, self.proxy_url)
      end

      def headers
        api_headers(self.read_key, "sync")
      end

      def api_query_resource_path(analysis_type)
        "/#{self.api_version}/projects/#{self.project_id}/queries/#{analysis_type}"
      end
    end
  end
end
