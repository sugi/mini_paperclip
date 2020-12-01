# MiniPaperclip

mini_paperclip is a subset of [paperclip](https://github.com/thoughtbot/paperclip)

# Guidelines

- Major API follow paperclip.
- Minor API and configuration changed from paperclip.
- Keep DB columns, S3 Objects and application code.
- Keep maintenable.
- Keep MINI.

# Usage

```
class Book < ActiveRecord::Base
  extend MiniPaperclip::ClassMethods
  has_attached_file :image
end

book = Book.find(id)
book.update!(book_params) # { image: ... }
book.image # #<MiniPaperclip::Attachment >
book.image.url # "http://..."
```

# Needed

## Columns

- \<attachment\>_file_name
- \<attachment\>_file_size
- \<attachment\>_content_type
- \<attachment\>_updated_at

## Command

[imagemagick](https://imagemagick.org/index.php)

# Writable data

```
book.image = ? # assign value to columns
book.save      # write file to storage
```

`?` is ...

- MiniPaperclip::Attachment # copy file
- ActionDispatch::Http::UploadedFile # in rails simple case
- url string e.g. "https://s3/bucket/key.png" # download contents from url
- data-uri string # read by base64 encoded string. but \<attachment\>_file_name could not set

#  Configuration

You can set configuration e.g initializers or environments

```
MiniPaperclip.config.tap do |config|
  config.storage          # default storage. `:filesystem` or `:s3`
  config.filesystem_path  # saving file path
  config.hash_data        # interpolated `:hash` base data
  config.hash_secret      # interpolated `:hash` secret
  config.styles           # default styles
  config.url_scheme       # 'http' or 'https'
  config.url_host         # host name for `url`
  config.url_path         # path for `url` and S3 object
  config.url_missing_path # path when not attached
  config.s3_host_alias    # CDN host name
  config.s3_bucket_name   # should set when storage = :s3
  config.s3_acl           # s3 object acl
  config.s3_cache_control # Set this value to Cache-Control header when put-object
  config.interpolates     # minimum templates using by `String#gsub!`
  config.read_timeout     # timeout when attachment set url
  config.logger           # You can set logger object.
end
```

And any configuration can overwrite by attachment.

```
class Book < ActiveRecord::Base
  has_attached_file :image,
    styles: { medium: "500x500#" },
    s3_host_alias: ENV['CLOUD_FRONT_DOMAIN'],
    hash_data: ':attachment/:id/:updated_at'
    ...
```

# Validation

```
class Book < ActiveRecord::Base
  extend MiniPaperclip::ClassMethods
  has_attached_file :image
  validates_attachment :image,
    content_type: { content_type: ["image/jpeg", "image/png"] },
    size: { less_than: 1.megabytes },
    if: :need_validation?
end
```

# Interpolate

Interpolate is a simple template system like this.

template: `:class/:attachment/:id/:hash.:extension`
result: `books/images/1234/abcdef1234567.png`

You can check default interpolates.

```
p MiniPaperclip.config.interpolaters
```

You can add any interpolate key and process.

```
MiniPaperclip.config.interpolates[/:custom_style/] = -> (style) {
  # This block is called by the scope in the instance of the Interpolator
  # You can also call `attachment` and `config` in this block
}
```

# Security

Paperclip had a security issue.

http://homakov.blogspot.com/2014/02/paperclip-vulnerability-leading-to-xss.html

Security and Performance has a serious performance tradeoff.

mini_paperclip take security very seriously.

## Force validate spoof media type

mini_paperclip force validate content-type both metadata and content same as paperclip.

## Read content-type from content only

mini_paperclip don't read metadata from HTTP responce or data-uri.

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_paperclip'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mini_paperclip

# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reproio/mini_paperclip. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/reproio/mini_paperclip/blob/master/CODE_OF_CONDUCT.md).


# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Code of Conduct

Everyone interacting in the MiniPaperclip project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/reproio/mini_paperclip/blob/master/CODE_OF_CONDUCT.md).
