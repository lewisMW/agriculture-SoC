//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2021-2022 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
// Release Information : DMA350-r0p0-00rel0
//
//----------------------------------------------------------------------------


function automatic bit address_map_m1 (
  input [<<ADDR_WIDTH>>-1:0] axaddr,
  input                [2:0] axprot
);
bit res;
begin
  res = '0;
  if (axaddr[27] == '1) res = '1;
  return res;
end
endfunction
