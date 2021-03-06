# Treblle SDK for Ruby on Rails

Treblle makes it super easy to understand what’s going on with your APIs and the apps that use them. Just by adding Treblle to your API out of the box you get:

* Real-time API monitoring and logging
* Auto-generated API docs with OAS support
* API analytics
* Quality scoring
* One-click testing
* API managment on the go
* and more...

## Requirements
* Ruby 2.0+
* Ruby on Rails 4.0+

## Setup

Add the gem to your Gemfile:

```rb
# Gemfile
gem "treblle", "~> 1.0.3"
```

Then add following line to `config/application.rb`, or if you want to include it to specific environment only, then e.g. `config/environments/development.rb` which registers Treblle middleware.

```rb
config.middleware.use(Treblle)
```

Finally, make sure to set environemnt variables as described below:

| Variable                | Description                                                                      |
| :----------------       | :--------------------------------------------------------------------------------|
| TREBLLE_API_KEY         | (required) Valid API key obtained during registration on treblle.com             |
| TREBLLE_PROJECT_ID      | (required) Valid Project ID obtained after creating a new project on treblle.com |
| TREBLLE_SENSITIVE_FIELDS| (optional) Additional optional keys that will be masked before sending to Treblle|

`TREBLLE_SENSITIVE_FIELDS` should be comma separated values like: `cc_number,cvv,dont_show_this_field`.

Note: if using `dotenv` or similar library in development to load environment variables, make sure to have this gem loaded AFTER dotenv, othewise variables may not be set. To be on the safe side when running locally you can use `export` command. In production make sure these variables are set following provider service docs.

## License

The gem is available as open source under the terms of the [MIT License].
