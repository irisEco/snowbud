# 文件相关操作
# Utils::Document.download(xxx, xxx)
module Utils
  class Document
    class << self

      # 将远程文件地址下载至本地
      def download(file_url, dic_name = "deercal")
        return if file_url.blank?
        _file_url = URI.escape(file_url)
        target_path = local_path_from(_file_url, dic_name)
        FileUtils.mkdir_p(File.dirname(target_path))
        IO.copy_stream(open(_file_url), target_path)
        target_path
      end

      # 根据远程文件地址删除本地的文件
      def remove(file_url, dic_name = "deercal")
        return if file_url.blank?
        _file_url = URI.escape(file_url)
        target_path = local_path_from(_file_url, dic_name)
        FileUtils.rm_rf(File.dirname(target_path))
      end

      # 根据远程文件地址构建本地文件地址
      def local_path_from(file_url, dic_name = "deercal")
        Application.root.join("tmp", dic_name, sanitize_filename(URI.parse(file_url).path[1..-1]))
      end

      private

      # 处理文件名
      # encode之后的文件名中有百分号，导致导出的图片显示不出来
      def sanitize_filename(filename)
        return filename.strip.gsub(/%/, "")
      end
    end
  end
end
