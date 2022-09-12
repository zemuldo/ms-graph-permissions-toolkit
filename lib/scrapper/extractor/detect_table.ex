defmodule Scrapper.ExTractor.DetectTable do
  alias Scrapper.ExTractor.PermissionName

  def is_permissions_table([
        {"thead", [],
         [
           {"tr", [],
            [
              {"th", _style1, _, _1},
              {"th", _style2, delegated_ws, _2},
              {"th", _style3, delegated_msa, _3},
              {"th", _style4, application, _4}
            ], _5}
         ], _6}
        | _7
      ]) do
    PermissionName.is_valid(delegated_ws) and PermissionName.is_valid(delegated_msa) and
      PermissionName.is_valid(application)
  end

  def is_permissions_table([
        {"thead", [],
         [
           {"tr", [],
            [
              {"th", _style1, ["Permission type"], _1} | _
            ], _4}
         ], _5}
        | _
      ]) do
    true
  end

  def is_permissions_table([
        {"thead", [],
         [
           {"tr", [],
            [
              {"th", _style1, ["Permission Type"], _1},
              {"th", _style2, _2, _3}
            ], _4}
         ], _5}
        | _
      ]) do
    true
  end

  def is_permissions_table([
        {"thead", [],
         [
           {"tr", [],
            [
              {"th", _style1, ["Supported resource"], _1} | _
            ], _4}
         ], _5}
        | _
      ]) do
    true
  end

  def is_permissions_table(_) do
    false
  end
end
