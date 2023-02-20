module Modules
  module RandomIdOwnerLib

    extend ActiveSupport::Concern

    included do
      before_create :set_random_ids
    end

    module ClassMethods
      attr_accessor :random_id_field_names, :random_id_options

      def random_id_field field_name, options
        if self.random_id_field_names.blank?
          self.random_id_field_names = []
          self.random_id_options = []
        end
        self.random_id_field_names << field_name
        self.random_id_options << options
      end

      def is_id_unique?(random_id, field_name)
        !self.exists?(field_name => random_id)
      end
    end

    # protected

    def set_random_ids
      self.class.random_id_field_names.each_with_index do |field, index|
        self[field] = generate_random_id(field, self.class.random_id_options[index])
      end
    end

    # Returns a random generator that is setup to generate random IDs. If a different,
    # non-basic setup is required, override this method and create a different random
    # generator.
    def random_number_generator(options)
      Modules::RandomNumberGenerator.new(options)
    end

    def generate_random_id(field_name, options)
      uniqueness_test = Proc.new { |candidate| self.class.is_id_unique?(candidate, field_name) }
      random_number_generator(options).generate(uniqueness_test, self.class.all.count)
    end

  end
end
