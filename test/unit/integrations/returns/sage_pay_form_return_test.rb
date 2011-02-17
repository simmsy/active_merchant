require 'test_helper'

class SagePayFormReturnTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @options = {:credential2 => 'EncryptionKey123'}
  end

  def test_successful_purchase
    r = SagePayForm::Return.new(successful_purchase, @options)
    assert r.success?
    assert_equal 'Successfully Authorised Transaction', r.message
  end

  def test_failed_purchase
    r = SagePayForm::Return.new(failed_purchase, @options)
    assert !r.success?
    assert_equal 'NOTAUTHED message generated by Simulator', r.message
  end

  def test_bogus_crypt
    r = SagePayForm::Return.new('crypt=SomeInvalidCryptField', @options)
    assert !r.success?
    assert_equal 'Invalid data received from SagePay', r.message
  end

  def test_missing_crypt
    r = SagePayForm::Return.new('other=stuff', @options)
    assert !r.success?
    assert_equal 'No data received from SagePay', r.message
  end

  def test_missing_key
    r = SagePayForm::Return.new(successful_purchase, {})
    assert !r.success?
    assert_equal 'No merchant decryption key supplied', r.message
  end

  def test_notification
    r = SagePayForm::Return.new(successful_purchase, @options)

    assert r.notification
    assert_kind_of SagePayForm::Notification, r.notification
    assert r.notification.complete?
    assert_equal 'Successfully Authorised Transaction', r.notification.message
  end

  private
  def successful_purchase
    'utm_nooverride=1&crypt=FhoCBgwDSSYkSBgRGEVHQAELFxMQHEk6Gg0oAApCVEYpAhpSOAUAAQAcIhYcVRJnNw8NARgTAAAAAG0zHF9WXDc6GzEWFBFUXVZtMyliZksMCl4JSzRHXl8seydUBwsBAUNXNklHWStZX31IQABwC3MtIDY/SEEoEkgfHThERlsLAV5FSkRNTy4DJBAXRQ8AdEBXRV8xIjosOHlYOH1+EwgvNzExVjUNCxwuFgpjV0AwAhdPNDEgKicrD0MpXkFHBgEHFysVBxwDGnYoOGVxewAqRTEvQiYMHBsnEUR8c2cGJiY2XzcdDxsvIgFEARQAAT0GEQwCETobDz8QCgx9eGMtIiQvTTknKFYRJDN1eGEQJTRLSTczMDUgHy1fclNBIToaAhxNIiA8L20pGEJGBwEHBBsNA0lRXFt9'
  end

  def failed_purchase
    'utm_nooverride=1&crypt=FhoCBgwDSScgOgowLXl3d2M9FxMNBQctChoqDBUMfHwRLzYmMTUwSQILOBYYVlcTIgsNFwsRAAwLTikcWWJbXjACAgYWAlI/CgAvCgtlSnAqCgZPS0hSPz89Hx0wVQ9IdypQRUkyRCtCWHJXPRwGd3VZTjBPQUJEVl8JXU9ycXcDVlYzBFY1BAAbJRFEAgMdcVlFMy8jNz9dUwopNRF/chEtK1Q4FBAbCh04NxxCR18xUy4zLTM8LCtIGwoKRXFcIQsxFwoFGB1SIwoxOnl3d2MtNUArFQccAxp2KDhlcXsAKkU1EBYAKAYKdlVfAnZgIA0WABwjAAgbGzhYNnoUcAQ4NU80PiIjNjcTPTF8cX0NXiE9LTIgUFg0bSYYQ1ZnPB4GTy85JyhJIioWDQV2WiIHFwFEREdcXA=='
  end
end
