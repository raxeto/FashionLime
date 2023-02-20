module Modules
  module EsIndexedModel

    extend ActiveSupport::Concern

    included do
      after_commit on: [:create] do
        Rails.logger.debug("Indexing #{self.class.name} ID: #{self.id}")
        Modules::DelayedJobs::EsIndexer.schedule('index_document', self)
      end

      after_commit on: [:update] do
        Rails.logger.debug("Updating #{self.class.name} ID: #{self.id}")
        Modules::DelayedJobs::EsIndexer.schedule('update_document', self)
      end

      after_commit on: [:destroy] do
        Rails.logger.debug("Deleting #{self.class.name} ID: #{self.id}")
        Modules::DelayedJobs::EsIndexer.schedule('delete_document', self)
      end
    end
  end
end