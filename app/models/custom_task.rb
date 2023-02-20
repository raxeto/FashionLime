class CustomTask < ActiveRecord::Base

  def self.is_in_progress(task_code)
    task = CustomTask.find_by_code(task_code)
    return task.present? && task.in_progress == 1
  end

  def self.begin_execute(task_code)
    update_in_progress(task_code, 1)
  end

  def self.end_execute(task_code)
    update_in_progress(task_code, 0)
  end

  private

  def self.update_in_progress(task_code, in_progress_value)
    task = CustomTask.find_by_code(task_code)
    if task.blank?
      return
    end
    success = true
    begin
      success = task.update_attributes(:in_progress => in_progress_value)
    rescue StandardError => e
      success = false
    end
    if !success
      AdminMailer.new_problem_occurred_email("There was a problem during custom task in progress change. Task is #{task_code}, in progress is #{in_progress_value}.").deliver_now
    end
  end

end
