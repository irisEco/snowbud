module Qiniu
  class Pfop
    # 多文件压缩:
    #   - https://developer.qiniu.com/dora/manual/1667/mkzip
    #   - 注意
    #     1: 支持异步的pfop操作
    #     2: 不支持压缩打包空文件
    class Mkzip

      attr_accessor :opts, :key

      def initialize(opts = {})
        @opts = opts
        @key  = opts[:key]
      end

      def package
        str = "mkzip/2/encoding/#{Qiniu::Utils.urlsafe_base64_encode("utf-8")}/#{url_alias_encodes.join()}"
        str.bytesize < 2048 ? package_2 : package_4
      end

      def package_2
        fops = <<~END.squish
          mkzip/2
          /encoding/#{Qiniu::Utils.urlsafe_base64_encode("utf-8")}
          #{url_alias_encodes.join()}
          |saveas/#{saveas_key(2)}
        END

        fops = fops.squish.chomp.gsub(' ', '')
        pfops = Qiniu::Fop::Persistance::PfopPolicy.new(bucket, key, fops, nil)

        pfops.pipeline = SERVICES_CONFIG.dig("qiniu", "pipeline")["image"]
        # pfops.force!

        Qiniu::Fop::Persistance.pfop(pfops)
      end

      def package_4
        begin
          file = File.open("#{Application.config.root}/tmp/import/#{SecureRandom.uuid}.txt", "a+")
          file.write(url_alias_encodes.join("\n"))
        rescue IOError => e
        ensure
          file.close unless file == nil
        end

        key = "deercal/mkzip/4/#{SecureRandom.uuid}.txt"
        uptoken = qiniu_upload_token(key)

        code, result, resp_headers = Qiniu::Storage.upload_with_token_2(
          uptoken,
          file,
          key,
          nil,
          bucket: bucket
        )

        File.delete(file) if File.exist?(file.path)
        LazyLogger.qiniu.info "upload qiniu mkzip_4: code: #{code}, result: #{result}"

        return code, result, resp_headers unless code.eql?(200) && result['key']

        fops = <<~END.squish
          mkzip/4
          /encoding/#{Qiniu::Utils.urlsafe_base64_encode("utf-8")}
          |saveas/#{saveas_key(4)}
        END

        fops = fops.squish.chomp.gsub(' ', '')
        pfops = Qiniu::Fop::Persistance::PfopPolicy.new(bucket, result['key'], fops, nil)

        pfops.pipeline = SERVICES_CONFIG.dig("qiniu", "pipeline")["image"]
        # pfops.force!
        Qiniu::Fop::Persistance.pfop(pfops)
      end

      def bucket
        @_bucket ||= SERVICES_CONFIG.dig("qiniu", "bucket")
      end

      def package_name
        opts[:package_name] || "#{SecureRandom.uuid}.zip"
      end

      def files
        return @_files if @_files

        files = opts[:files] || []
        files.each_with_index do |file, index|
          file_name = file_name(file)
          file_name = "#{index + 1}-#{file_name}"

          file[:alias_name] = file_name
        end

        @_files = files
      end

      def file_name(file = {})
        return file[:alias_name] if file[:alias_name].present?
        return file[:file_name] if file[:file_name].present?

        File.basename(file[:file_url])
      end

      def url_alias_encodes
        @_url_alias_encodes ||= files.each_with_object([]) do |file, arr|
          str = <<~END.squish
            /url/#{Qiniu::Utils.urlsafe_base64_encode(file[:file_url])}
            /alias/#{Qiniu::Utils.urlsafe_base64_encode(file[:alias_name])}
          END

          arr << str.squish.chomp.gsub(' ', '')
        end
      end

      def saveas_key(mode)
        save_key = "#{bucket}:deercal/mkzip/#{mode}/#{SecureRandom.uuid}/#{package_name}"

        Qiniu::Utils.urlsafe_base64_encode(save_key)
      end

    end

    class << self
      # === Example
      #   data = {
      #     files: [
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" },
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" },
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" },
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" },
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" },
      #       { file_url: "https://files-pro.deercal.com/materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png", file_name: "点线图.png", alias_name: "点线图.png" }
      #     ],
      #     key: "materials/undefined/a011c4ed-4319-428f-a86b-3792d751dc1e/点线图.png",
      #     package_name: "test.zip"
      #   }
      #   Qiniu::Pfop.mkzip(data)
      def mkzip(data = [])
        pfop = Qiniu::Pfop::Mkzip.new(data)
        pfop.package
      end

      def mkzip_res(persistent_id)
        Qiniu::Fop::Persistance.prefop(persistent_id)
      end

    end

  end
end