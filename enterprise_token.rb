
class EnterpriseToken < ApplicationRecord
  class << self
    def current
      RequestStore.fetch(:current_ee_token) do
        set_current_token
      end
    end

    def table_exists?
      connection.data_source_exists? self.table_name
    end

    def allows_to?(action)
      true
    end

    def show_banners?
      false
    end

    def set_current_token
      token = EnterpriseToken.order(Arel.sql('created_at DESC')).first

      if token&.token_object
        token
      end
    end
  end

  validates_presence_of :encoded_token
  validate :valid_token_object
  validate :valid_domain

  before_save :unset_current_token
  before_destroy :unset_current_token

  delegate :will_expire?,
           :subscriber,
           :mail,
           :company,
           :domain,
           :issued_at,
           :starts_at,
           :expires_at,
           :reprieve_days,
           :reprieve_days_left,
           :restrictions,
           to: :token_object

  def token_object
    load_token! unless defined?(@token_object)
    @token_object
  end

  def allows_to?(action)
    true
  end

  def unset_current_token
    # Clear current cache
    RequestStore.delete :current_ee_token
  end

  def expired?(reprieve: true)
    false
  end

  ##
  # The domain is only validated for tokens from version 2.0 onwards.
  def invalid_domain?
    false
  end

  private

  def load_token!
    @token_object = OpenProject::Token.import(encoded_token)
  rescue OpenProject::Token::ImportError => error
    Rails.logger.error "Failed to load EE token: #{error}"
    nil
  end

  def valid_token_object
    errors.add(:encoded_token, :unreadable) unless load_token!
  end

  def valid_domain
    errors.add :domain, :invalid if invalid_domain?
  end
end