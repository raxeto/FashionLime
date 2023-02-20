require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "guest user creation" do
    user = User.create_guest_user
    assert user.valid? and user.errors.empty? and user.guest?

    user = User.create_guest_user
    assert user.valid? and user.errors.empty? and user.guest?
  end

  test "address creation" do
    rali = User.find(3)
    assert rali.addresses.empty?

    rali.addresses.create(location_id: 4, description: 'Krasna Poliana')
    assert !rali.addresses(true).empty?
  end

  test "inactive user" do
    rali = User.find(3)
    assert rali.active_for_authentication?

    rali.not_active!
    assert !rali.active_for_authentication?
  end

  test "transfer addresses between users" do
    rali = User.find(3)
    assert rali.addresses.empty?

    guest = User.find(4)
    assert guest.addresses.empty?

    guest.assign_addresses(nil)
    assert guest.addresses.empty?

    guest.assign_addresses([])
    assert guest.addresses.empty?

    guest.addresses.create(location_id: 4, description: 'Krasna Poliana')
    assert !guest.addresses(true).empty?
    assert rali.addresses(true).empty?
    address_id = guest.addresses[0].id

    rali.assign_addresses(guest.addresses)
    assert guest.addresses(true).empty?
    assert !rali.addresses(true).empty?
    assert rali.addresses[0].id == address_id
  end

  test "transfer_outfits between users" do
    guest = User.find(4)
    assert guest.outfits.empty?

    # Add some outfits
    guest.outfits.create(name: 'viziq1')
    guest.outfits.create(name: 'viziq2')
    assert_equal 2, guest.outfits.count

    # Transfer the outfits
    rali = User.find(3)
    assert rali.outfits.empty?
    rali.transfer_outfits(guest.outfits)
    assert_equal 2, rali.outfits.count
  end

  test "test transfer attributes between users" do
    rali = User.find(3)
    assert rali.first_name.empty?
    assert rali.last_name.empty?
    assert !rali.gender.empty?
    assert !rali.phone.empty?

    guest = User.find(4)
    assert !guest.first_name.empty?
    assert !guest.last_name.empty?
    assert guest.gender.nil?
    assert !guest.phone.empty?

    rali.fill_empty_attributes_from(guest)
    # The changes should be persistent.
    rali.reload()
    guest.reload()

    # Rali should have been updated.
    assert !rali.first_name.empty?
    assert !rali.last_name.empty?
    assert !rali.gender.empty?
    assert !rali.phone.empty?

    # The guest shouldn't have been touched.
    assert !guest.first_name.empty?
    assert !guest.last_name.empty?
    assert guest.gender.blank?
    assert !guest.phone.empty?

    # The fields which were present in both instances shouldn't have been
    # changed in rali
    assert rali.first_name == guest.first_name
    assert rali.last_name == guest.last_name
    assert rali.username != guest.username
    assert rali.gender != guest.gender
    assert rali.phone != guest.phone
  end

end
