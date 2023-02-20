class ErrorsController < ClientController

  def show
    @error_code = status_code
    
    add_breadcrumb "Грешка #{@error_code}"

    case @error_code
    when "404"
     @error_message = "Страницата, която търсите, вече не съществува."
     @error_explanation = "Тя може да е била преместена, изтрита или да сте изписали грешно адреса ѝ."
    when "422" 
      @error_message = "Действието, което се опитвате да извършите, беше отхвърлено."
      @error_explanation = "Може би нямате необходимите права в системата, за да го направите."
    when "500" 
      @error_message = "Нещо се обърка."
    end
  end
 
protected
 
  def status_code
    params[:code] || 500
  end
 
end
