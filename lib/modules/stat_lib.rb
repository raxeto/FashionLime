module Modules
  module StatLib

    STAT_KEY_TO_MODEL = {
      :cart_deleted_articles => CartDeletedDetail
    }.freeze

    protected

    def log_user_stat(stat_name, params)
       params[:user_id] = current_or_guest_user.id

       log_stat(stat_name, params)
    end

    def log_stat(stat_name, params)
      active_record = STAT_KEY_TO_MODEL[stat_name]

      active_record.create(params)
      rescue ActiveRecord::ActiveRecordError
    end

  end
end
