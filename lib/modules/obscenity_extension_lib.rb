module ObscenityExtensionLib

  extend ActiveSupport::Concern

  module ClassMethods

    # Made in that way and not with alias_method because the method contains '?'
    def profane?(text)
      if text.present?
        text = text.squeeze
      end
      super(text)
    end

    def profane_without_squeeze?(text)
      method(:profane?).super_method.call(text)
    end

  end
end

# include the extension
Obscenity.send(:include, ObscenityExtensionLib)
