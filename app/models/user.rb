class User < ApplicationRecord
  has_many :attendances, dependent: :destroy 
  attr_accessor :remember_token
  before_save {self.email = email.downcase}
  
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 100},
                    format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :department, length: { in: 2..30 }, allow_blank: true
  validates :basic_work_time, presence: true, allow_nil: true
  validates :employee_id, presence: true
  validates :card_id, presence: true
  validates :designated_work_start_time, presence: true, allow_nil: true
  validates :designated_work_finish_time, presence: true, allow_nil: true
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  def self.import(file)  
    csv_header = { "name" => "name", "email" => "email", "affiliation" => "department", "employee_number" => "employee_id",
                  "uid" => "card_id", "basic_work_time" => "basic_work_time", "designated_work_start_time" => "designated_work_start_time",
                  "designated_work_finish_time" => "designated_work_finish_time", "superior" => "superior", "admin" => "admin", "password" => "password" }
    CSV.foreach(file.path, headers: true) do |row|
      user = find_by(email: row["email"]) || new
      row["basic_work_time"] = row["basic_work_time"].to_time if row["basic_work_time"].present?
      row["designated_work_start_time"] = row["designated_work_start_time"].to_time if row["designated_work_start_time"].present?
      row["designated_work_finish_time"] = row["designated_work_finish_time"].to_time if row["designated_work_finish_time"].present?
      if user.superior_name.blank? && row["superior"]
        sn = []
        User.where(superior: true).pluck(:superior_name).each {|s| sn << s.to_s.split("上長")[1].to_i}
        sn.uniq.sort.each_with_index do |n, i|
          row["superior_name"] = "上長#{i}" if n != i
          break if row["superior_name"].present?
        end
      elsif user.superior_name.present?
        row["superior_name"] = user.superior_name
      end
      row_hash = row.to_hash.slice(*csv_header.keys)
      user.attributes = row_hash.transform_keys(&csv_header.method(:[]))
      user.update_attributes(superior_name: row["superior_name"])
      user.save
    end
  end

  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

end
