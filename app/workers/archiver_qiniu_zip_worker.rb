class ArchiverQiniuZipWorker

  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: true, backtrace: false

  def perform(attachment_code)
    @attachment = Attachment.find_by(code: attachment_code)

    res = Qiniu::Fop::Persistance.prefop(@attachment.qiniu_persistent_id)
    return unless res[0].eql?(200)

    result = HashWithIndifferentAccess.new(res[1])
    if result[:code].in?([3, 4])
      Utils::DingNotifier.error("七牛打包失败：#{result}")
      return
    end

    if result[:code].in?([1, 2])
      ArchiverQiniuZipWorker.perform_at(3, attachment_code)
    end

    return unless result[:code].eql?(0)

    result[:items].each do |item|
      next unless item[:code].eql?(0)

      @attachment.update!(
        qiniu_hash: item[:hash],
        file_path: item[:key]
      )
    end
  end
end