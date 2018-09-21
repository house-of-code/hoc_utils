# HocUtils
This is a collection of utilities for a HoC API application

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hoc_utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hoc_utils

## Error handling

In the rescue controller you'll need to add this

```ruby
rescue_from HocUtils::ApiException, with: :handle_exception

# ...

def handle_exception(error)
    render json: { error: error.message }, status: error.http_code
end
```

### Raise exception

#### No Parameters

When you want to raise an exception you'll need to raise inside a controller

```ruby
class SessionsController < ApplicationController
    def login
        # Login logic
        raise HocUtils::ApiException::LoginWrongPassword unless user.authenticate(password)
    end
end
```

### Messages and status codes

Messages and status code are placed inside the `config/locals/errors.en.yml` or just `config/locals/en.yml` and would look like the following:


```yaml
en:
    error:
        login_wrong_password:
            code: 1000
            http_code: 401
            message: "Username or password is not correct"
```

#### With parameters
```ruby
class SessionsController < ApplicationController
    def login
        # Parameter check
        unless params.include?(:username, :password)
        raise HocUtils::ApiException::MissingParameter(parameter: "username and password") unless user.authenticate(password)
    end
end
```

`config/locals/en.yml`:

```yaml
en:
    error:
        missing_parameter:
            code: 1001
            http_code: 400
            message: "Parameter %{parameter} is missing from body"
```


## TODO
* Routes for nested resources
* Generate client code
* DSL for specifying models and layout of admin pages


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
