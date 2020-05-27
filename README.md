# content_disposition.cr

[![Build Status](https://travis-ci.org/jetrockets/content_disposition.cr.svg?branch=master)](https://travis-ci.org/jetrockets/content_disposition.cr)
[![GitHub release](https://img.shields.io/github/release/jetrockets/content_disposition.cr.svg)](https://GitHub.com/jetrockets/content_disposition.cr/releases/)
[![GitHub license](https://img.shields.io/github/license/jetrockets/content_disposition.cr)](https://github.com/jetrockets/content_disposition.cr/blob/master/LICENSE)

Creating a properly encoded and escaped standards-compliant HTTP
`Content-Disposition` header for potential filenames with special characters is
surprisingly confusing.

This library does that and only that, in a single 50-line file with no dependencies.

Crystal port of [https://github.com/shrinerb/content_disposition](https://github.com/shrinerb/content_disposition)

## Content-Disposition header

Before we proceed with the usage guide, first a bit of explanation what is the
`Content-Disposition` header. The `Content-Disposition` response header
specifies the behaviour of the web browser when opening a URL.

The `inline` disposition will display the content "inline", which means that
known MIME types from the `Content-Type` response header are displayed inside
the browser, while unknown MIME types will be immediately downloaded.

```http
Content-Disposition: inline
```

The `attachment` disposition will tell the browser to always download the
content, regardless of the MIME type.

```http
Content-Disposition: attachment
```

When the content is downloaded, by default the filename will be last URL
segment. This can be changed via the `filename` parameter:

```http
Content-Disposition: attachment; filename="image.jpg"
```

To support old browsers, the `filename` should be the ASCII version of the
filename, while the `filename*` parameter can be used for the full filename
with any potential UTF-8 characters. Special characters from the filename need
to be URL-encoded in both parameters.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     content_disposition:
       github: jetrockets/content_disposition
   ```

2. Run `shards install`

## Usage

```crystal
require "content_disposition"

ContentDisposition.format(disposition: "inline", filename: "racecar.jpg")
# => "inline; filename=\"racecar.jpg\"; filename*=UTF-8''racecar.jpg"
```

A proper content-disposition value for non-ascii filenames has a pure-ascii
as well as an ascii component. By default the filename will be turned into ascii
by replacing any non-ascii chars with `'?'` (which is then properly
percent-escaped to `%3F` in output).

```crystal
ContentDisposition.format(disposition: "attachment", filename: "råcëçâr.jpg")
# => "attachment; filename=\"r%3Fc%3F%3F%3Fr.jpg\"; filename*=UTF-8''r%C3%A5c%C3%AB%C3%A7%C3%A2r.jpg"
```

But you can pass in your own proc to do it however you want.

```crystal
ContentDisposition.format(
  disposition: "attachment",
  filename: "råcëçâr.jpg",
  to_ascii: ->(filename : String) { String.new(filename.encode("US-ASCII", invalid: :skip)) }
)
# => "attachment; filename=\"racecar.jpg\"; filename*=UTF-8''r%C3%A5c%C3%AB%C3%A7%C3%A2r.jpg"
```

You can also configure `.to_ascii` globally for any invocation:

```crystal
ContentDisposition.to_ascii = ->(filename : String) { String.new(filename.encode("US-ASCII", invalid: :skip)) }
```

The `.format` method is aliased to `.call`, so you can do:

```crystal
ContentDisposition.(disposition: "inline", filename: "råcëçâr.jpg")
# => "inline; filename=\"r%3Fc%3F%3F%3Fr.jpg\"; filename*=UTF-8''r%C3%A5c%C3%AB%C3%A7%C3%A2r.jpg"
```

There are also `.attachment` and `.inline` shorthands:

```crystal
ContentDisposition.attachment("racecar.jpg")
# => "attachment; filename=\"racecar.jpg\"; filename*=UTF-8''racecar.jpg"
ContentDisposition.inline("racecar.jpg")
# => "inline; filename=\"racecar.jpg\"; filename*=UTF-8''racecar.jpg"
```

You can also create a `ContentDisposition` instance to build your own
`Content-Disposition` header.

```crystal
content_disposition = ContentDisposition.new(
  disposition: "attachment",
  filename:    "råcëçâr.jpg",
)

content_disposition.disposition
# => "attachment"
content_disposition.filename
# => "råcëçâr.jpg"

content_disposition.ascii_filename
# => "filename=\"r%3Fc%3F%3F%3Fr.jpg\""
content_disposition.utf8_filename
# => "filename*=UTF-8''r%C3%A5c%C3%AB%C3%A7%C3%A2r.jpg"

content_disposition.to_s
# => "attachment; filename=\"r%3Fc%3F%3F%3Fr.jpg\"; filename*=UTF-8''r%C3%A5c%C3%AB%C3%A7%C3%A2r.jpg"
```

## Contributing

1. Fork it (<https://github.com/jetrockets/content_disposition/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Igor Alexandrov](https://github.com/igor-alexandrov) - creator and maintainer
