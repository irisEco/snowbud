module Qinius
  class CallbackService
    attr_accessor :options, :attachment, :att_type

    def initialize(options)
      @options = HashWithIndifferentAccess.new(options)
    end

    def call
      return unless options.present?
      _options = {
        file_path: options[:key],
        file_name: options[:name],
        file_content_type: options[:mime_type],
        file_size: options[:filesize],
        extras: file_extras,
        qiniu_hash: options[:hash]
      }
      self.attachment = Attachment.create!(_options)
    end

    private

    # TODO 后续处理
    def file_extras
      {}
    end
  end
end
