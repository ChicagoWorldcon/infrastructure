# frozen_string_literal: true
#
# Copyright 2019 Matthew B. Gray
# Copyright 2019 Chris Rose
# Copyright 2020 Victoria Garcia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if User.count > 0 or Membership.count > 0 or Reservation.count > 0
  puts "Users already exist; please drop and re-create the DB in order to re-seed"
  puts "Run rake db:reset"
  exit 1
end
require "factory_bot_rails"


beginning_of_time = "2000-01-01".to_time

PriceGroup = Struct.new("PriceGroup", :start_time, :end_time, :supporting, :adult_attending, :ya, :child, :first_worldcon, :family_1_discount, :family_2_discount, :family_3_discount)
site_selection = "2020-07-30 18:00:00 CST".to_time
price_change_1 = "2021-04-30 23:59:00 CST".to_time
price_change_2 = "2021-11-30 23:59:00 CST".to_time
price_change_3 = "2022-04-30 23:59:00 CST".to_time
at_con = "2022-08-31 23:59:00 CST".to_time


prices = [
  PriceGroup.new(site_selection, price_change_1, Money.new(50_00), Money.new(170_00), Money.new(90_00), Money.new(60_00), Money.new(110_00), Money.new(40_00), Money.new(40_00), Money.new(50_00)),
  PriceGroup.new(price_change_1, price_change_2, Money.new(50_00), Money.new(190_00), Money.new(90_00), Money.new(60_00), Money.new(110_00), Money.new(50_00), Money.new(50_00), Money.new(60_00)),
  PriceGroup.new(price_change_2, price_change_3, Money.new(50_00), Money.new(210_00), Money.new(100_00), Money.new(60_00), Money.new(120_00), Money.new(60_00), Money.new(70_00), Money.new(90_00)),
  PriceGroup.new(price_change_3, at_con,         Money.new(50_00), Money.new(230_00), Money.new(100_00), Money.new(60_00), Money.new(140_00), Money.new(80_00), Money.new(80_00), Money.new(100_00)),
]

########################################################################
# Presupport membership types
Membership.create!(
  name: "Donor",
  price: Money.new(20_00),
  description: "With our thanks!",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

Membership.create!(
  name: "Friend",
  price: Money.new(150_00),
  description: "Will convert to an attending membership automatically if you vote in tion in 2020",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

Membership.create!(
  name: "Star",
  price: Money.new(500_00),
  description: "Will convert to an attending membership automatically if you vote in Site Selection in 2020, and something cool for you at the convention! (Shhh…it’s a surprise!)",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

########################################################################
# Actual Memberships

prices.each do |price_group|
  Membership.create!(
    name: "Supporting",
    description: "Supporting member of Chicon 8",
    price: price_group.supporting,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: false,
  )

  Membership.create!(
    name: "Adult Attending",
    description: "Attending adult member of Chicon 8",
    price: price_group.adult_attending,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "Child (6-15)",
    description: "Attending child member of Chicon 8 (6-15 at-con)",
    price: price_group.child,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
  )

  Membership.create!(
    name: "YA (16-25)",
    description: "Attending YA member of Chicon 8 (16-25 at-con)",
    price: price_group.ya,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "First Worldcon",
    description: "Attending their first worldcon",
    price: price_group.first_worldcon,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "Kid-in-Tow",
    description: "A child < 6 years old accompanied by an Adult member",
    price: Money.new(0),
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
  )
end

# Disable the presupports
Membership.active_at("2020-06-01".to_time).each do |m|
  m.active_to = "2020-05-31 23:59:00".to_time
  m.save!
end

# enable the at-con
Membership.active_at("2020-09-01".to_time).each do |m|
  m.active_from = "2020-05-31 23:59:00".to_time
  m.save!
end

# Generate fake users
membership_distribution_averages = [
  1,1,1,1,1,1,1,1,1,1, # 10/20 will be Individuals,
  2,2,2,2,2,           # 5/20 will be Couples,
  3,3,3,               # 3/20 will be Small families,
  5,5,                 # 2/20 will be Families
]

all_memberships = Membership.active_at "2020-07-01".to_time

50.times do |count|
  new_user = FactoryBot.create(:user)
  memberships_held = membership_distribution_averages.sample # <-- biased random number

  all_memberships.sample(memberships_held).each do |rando_membership|
    FactoryBot.create(:reservation, user: new_user, membership: rando_membership, state: Reservation::PAID)
  end

  new_user.active_claims.each do |claim|
    claim.update!(contact: FactoryBot.create(:chicago_contact, claim: claim))
  end

end

support = Support.create(
  email: "chicago+support@offby1.net",
  password: 111111,
  confirmed_at: Time.now,
)
puts
puts "Support user created"
puts "https://registration.dev.chicon.org/supports/sign_in"
puts "user: #{support.email}"
puts "pass: 111111"
puts
