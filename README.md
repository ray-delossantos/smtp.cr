# smtp.cr

SMTP client in Crystal

## Deprecated

Please use this, as thsi shard won't be supported anymore:
https://github.com/arcage/crystal-email


## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  smtp:
    github: raydf/smtp.cr
```


## Usage


```crystal
require "smtp"

client = SMTP::Client.new("localhost")

message = SMTP::Message.new()
message.from = SMTP::Address.new(email="info@test.com", name="Test")
message.to << SMTP::Address.new(email="test@mail.com", name="Name")
message.subject = "Testing message"
message.body = %{
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml">
   <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Demystifying Email Design</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </head>
  <body>Test <h1><strong>HTML</strong></h1></body>
  </html>
}

client.send message

```

## Development

TODO: Write development instructions here

## Alternative shard/lib

https://github.com/arcage/crystal-email

## Contributing

1. Fork it ( https://github.com/raydf/smtp.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[raydf]](https://github.com/raydf) Rayner De Los Santos - creator, maintainer
