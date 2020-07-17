module Utils
  class EmojiTranslate
    def self.emoji_encode(source)
      return source if source.blank? or !source.is_a?(String)

      Rumoji.encode source
    end

    def self.emoji_decode(source)
      return source if source.blank? or !source.is_a?(String)

      Rumoji.decode source
    end
  end
end
