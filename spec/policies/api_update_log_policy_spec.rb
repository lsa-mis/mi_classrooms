# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiUpdateLogPolicy do
  subject(:policy) { described_class.new(user, api_update_log) }

  let(:api_update_log) { ApiUpdateLog.new(status: 'success', result: 'ok') }

  describe 'viewer access' do
    let(:user) do
      build_stubbed(:user).tap do |viewer|
        viewer.membership = ['mi-classrooms-non-admin-staging']
        viewer.admin = false
      end
    end

    it 'denies index and show' do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
    end
  end

  describe 'admin access' do
    let(:user) do
      build_stubbed(:user).tap do |admin|
        admin.membership = ['mi-classrooms-admin-staging']
        admin.admin = true
      end
    end

    it 'allows index and show' do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
    end
  end
end
