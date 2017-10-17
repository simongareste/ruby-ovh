module OVHApi
  class OVHApiError < RuntimeError; end
  class OVHApiNotConfiguredError < OVHApiError; end
  class OVHApiNotImplementedError < OVHApiError; end
end
