class Admin::RequestsController < AdminController

public

  def index
    @data = RequestExecutionTime.order(:created_at).last(700)
    @num_requests = RequestExecutionTime.where(measure_type: 'max').order(:created_at).last(700)
  end

end
