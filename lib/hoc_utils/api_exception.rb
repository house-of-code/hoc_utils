module HocUtils
    class ApiException < StandardError

        attr_accessor :code, :http_code, :message

        def initialize(hash)
            @code = hash[:code]
            @http_code = hash[:http_code]
            @message = hash[:message]
        end


    end

    def ApiException.const_missing(name)
        I18n.reload!

        hash = ApiException.t(name)
        puts hash
        if hash.is_a? Hash
            ApiException.new hash
        else
            super
        end
    end

    def ApiException.method_missing(name, *args, &block)
        I18n.reload!

        hash = ApiException.t(name, args[0] || [])

        if hash.is_a? Hash
            ApiException.new hash
        else
            super
        end


    end

    def ApiException.t(name, args = {})   
        l18name = "error.#{name.to_s.underscore}"

        unless I18n.exists?(l18name)
            return nil
        end

        http_code = nil
        code = nil


        http_code = args[:http_code] if args.has_key?(:http_code)
        code = args[:code] if args.has_key?(:code)

        message = I18n.t("#{l18name}.message", args)
        http_code = I18n.t("#{l18name}.http_code") if http_code.nil?
        code = I18n.t("#{l18name}.code") if code.nil?

        return {
            message: message,
            http_code: http_code,
            code: code
        }



    end
end