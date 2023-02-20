class LegalController < ClientController

  add_breadcrumb "Общи условия", :terms_of_use_path, only: [:terms_of_use]
  add_breadcrumb "Бисквитки", :cookies_policy_path, only: [:cookies_policy], options: { title: "Политика за използване на бисквитки" }
  add_breadcrumb "Поверителност", :privacy_policy_path, only: [:privacy_policy], options: { title: "Политика за поверителност" }

end
