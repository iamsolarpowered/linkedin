module LinkedIn
  module Api

    module QueryMethods

      def profile(options={})
        path = person_path(options)
        simple_query(path, options)
      end

      def connections(options={})
        path = "#{person_path(options)}/connections"
        simple_query(path, options)
      end

      def network_updates(options={})
        path = "#{person_path(options)}/network/updates"
        simple_query(path, options)
      end

      def job_search(options={})
        path = job_search_path(options)
        result_json = get path
        Mash.from_json(result_json)
      end

      def company(options = {})
        path   = company_path(options)
        simple_query(path, options)
      end
      
      def company_search(options = {})
        path = "/company-search:(companies)"
        path += "?keywords=#{CGI.escape(options[:keywords])}"
        result_json = get(to_uri(path, options))
        Mash.from_json(result_json)
      end

      private

        def simple_query(path, options={})
          fields = options[:fields] || LinkedIn.default_profile_fields

          if options[:public]
            path +=":public"
          elsif fields
            path +=":(#{fields.map{ |f| f.to_s.gsub("_","-") }.join(',')})"
          end
          headers = options[:headers] || {}
          Mash.from_json(get(path, headers))
        end

        def person_path(options)
          path = "/people/"
          if options[:id]
            path += "id=#{options[:id]}"
          elsif options[:url]
            path += "url=#{CGI.escape(options[:url])}"
          else
            path += "~"
          end
        end

        def company_path(options)
          path = "/companies/"
          if options[:id]
            path += "id=#{options[:id]}"
          elsif options[:url]
            path += "url=#{CGI.escape(options[:url])}"
          elsif options[:name]
            path += "universal-name=#{CGI.escape(options[:name])}"
          elsif options[:domain]
            path += "email-domain=#{CGI.escape(options[:domain])}"
          else
            path += "~"
          end
        end

        def job_search_path(options)
          path = "/job-search"
          if fields = options.delete(:fields)
            path += ":(jobs:(#{format_fields(fields)}))"
          end
          query_pairs = options.inject([]) { |pairs, (key, value)| pairs + make_query_pairs(key, value) }
          query_string = query_pairs.collect { |name, value| "#{CGI.escape(name)}=#{CGI.escape(value)}" }.join('&')
          path += "?#{query_string}" if query_string
          path
        end

        def format_fields(fields)
          fields.map{ |f| f.to_s.gsub("_","-") }.join(',')
        end

        def make_query_pairs(key, value)
          key = key.to_s
          [value].flatten.compact.collect { |v| [key, v.to_s] }
        end
    end

  end
end
