module HocUtils
    class ApiException < StandardError

        def initialize(hash)
            @code = hash[:code]
            @http_code = hash[:http_code]
            @message = hash[:message]
        end


    end

    def ApiException.const_missing(name)
        I18n.reload!

        hash = ApiException.t(name)
        if hash.is_a? Hash
            ApiException.new hash
        else
            super
        end
    end

    def ApiException.t(name)
        I18n.t("errors.#{name.to_s.underscore}")
    end
end