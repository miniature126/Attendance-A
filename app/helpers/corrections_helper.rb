module CorrectionsHelper
  #idから上長の情報を取得して名前を返す
  def superior_name(id)
    return User.find(id).name
  end
end
