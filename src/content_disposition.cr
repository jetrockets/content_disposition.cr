class ContentDisposition
  ATTACHMENT = "attachment"
  INLINE     = "inline"

  DEFAULT_TO_ASCII = ->(filename : String) do
    String.new(filename.encode("US-ASCII", invalid: :skip))
  end

  # class << self

  class_property to_ascii : Proc(String, String) | Nil = nil

  def self.attachment(filename = nil)
    format(disposition: ATTACHMENT, filename: filename)
  end

  def self.inline(filename = nil)
    format(disposition: INLINE, filename: filename)
  end

  def self.format(**options)
    new(**options).to_s
  end

  # alias call format

  # property :to_ascii
  # end

  getter :disposition, :filename, :to_ascii

  # def initialize(disposition : String, filename : String, to_ascii: nil)
  def initialize(disposition : String, filename : String, to_ascii : Proc(String, String) | Nil = nil)
    unless [ATTACHMENT, INLINE].includes?(disposition.to_s)
      raise ArgumentError.new "unknown disposition: #{disposition.inspect}"
    end

    @disposition = disposition
    @filename = filename
    @to_ascii = to_ascii || self.class.to_ascii || DEFAULT_TO_ASCII
  end

  def to_s
    if filename
      "#{disposition}; #{ascii_filename}; #{utf8_filename}"
    else
      "#{disposition}"
    end
  end

  TRADITIONAL_ESCAPED_CHAR = /[^ A-Za-z0-9!#$+.^_`|~-]/

  def ascii_filename
    "filename=\"" + percent_escape(to_ascii.not_nil!.call(filename), TRADITIONAL_ESCAPED_CHAR) + "\""
  end

  RFC_5987_ESCAPED_CHAR = /[^A-Za-z0-9!#$&+.^_`|~-]/

  def utf8_filename
    "filename*=UTF-8''" + percent_escape(filename, RFC_5987_ESCAPED_CHAR)
  end

  private def percent_escape(string, pattern)
    string.gsub(pattern) do |char|
      char.bytes.map { |byte| "%%%02X" % byte }.join
    end
  end
end
