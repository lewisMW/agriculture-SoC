/******************************************************************************/
/* The confidential and proprietary information contained in this file may    */
/* only be used by a person authorised under and to the extent permitted      */
/* by a subsisting licensing agreement from Arm Limited or its affiliates.    */
/*                                                                            */
/* (C) COPYRIGHT 2022 Arm Limited or its affiliates.                          */
/* ALL RIGHTS RESERVED                                                        */
/*                                                                            */
/* This entire notice must be reproduced on all copies of this file           */
/* and copies of this file may only be made by a person if such person is     */
/* permitted to do so under the terms of a subsisting license agreement       */
/* from Arm Limited or its affiliates.                                        */
/*                                                                            */
/* Release Information : DMA350-r0p0-00rel0                                   */
/*                                                                            */
/******************************************************************************/

 #ifndef __DMA_COMMAND_LIB_C
 #define __DMA_COMMAND_LIB_C

#include <stdio.h>
#include "dma_350_command_lib.h"

// Channel pointers
DMACH_TypeDef *sec_dma_channels[3] =  { DMACH0_S,  DMACH1_S, DMACH2_S};

DMACH_TypeDef *nsec_dma_channels[3] =  { DMACH0_NS,  DMACH1_NS, DMACH2_NS};

//
// Get DMA channel register frame based on security and channel number
//
DMACH_TypeDef* GetChannelPtr(uint32_t ch_num, uint8_t security)
{
  if (ch_num<ADA_MAX_CH_NUM)
  {
    if (security==0)
    {
      return sec_dma_channels[ch_num];
    }
    else if (security==1)
    {
      return nsec_dma_channels[ch_num];
    }
    else
    {
      printf("Error - Security must be 0 or 1");
      return sec_dma_channels[ch_num];
    }
  }
  else
  {
    printf("Error - Pointer for Channel %d is not defined", ch_num);
    return sec_dma_channels[0];
  }
}

//
// Dma Enable a Channel
// Channel Enable. When set to '1', enable to channel to run its programmed task. When set to '1', it cannot be set back to zero,
// and this field will automatically clears to zero when a DMA process is completed. To force the DMA to stop prematurely,
// you must use CH_CMD.STOPCMD instead.
//
void AdaEnable(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_ENABLECMD_Msk;
}

uint8_t AdaGetEnable(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CMD;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CMD.w = actual_frame->CH_CMD;

  // Return actual status
  return CMD.b.ENABLECMD;
}

//
// Dma Stop a Channel
// Stop Current DMA Operation. Once set to '1', his will remain high until the DMA is stopped cleanly. Then this will return to '0' and ENABLECMD is also cleared.
//
void AdaStop(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_STOPCMD_Msk;
}

//
// Dma Disable a Channel
// Stop DMA Operation at the end of current DMA command operation. Once set to '1', this field will stay high and the current DMA command will be allowed to complete,
// but the DMA will not fetch the next linked command or will it auto-restart the DMA command even if they are set. Once the DMA has stopped,
// it will return to '0' and ENABLECMD is also cleared.
//
void AdaDisable(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_DISABLECMD_Msk;
}

//
// Dma Clear a Channel
// DMA Clear command. When set to '1', it will remain high until all DMA Channel registers and any internal queues and buffers are cleared,
// before returning to '0'. When set while the DMA channel is enabled, the clear will only occur after any ongoing DMA operation is either completed,
// stopped or disabled.
//
void AdaClear(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_CLEARCMD_Msk;
}

//
// Dma Pause a Channel operation
// Pause Current DMA Operation. Once set to '1' the status cannot change until the DMA operation reached the paused state indicated by the STAT_PAUSED and STAT_RESUMEWAIT bits.
// The bit can be set by SW by writing it to '1', the current active DMA operation will be paused as soon as possible, but the ENABLECMD bit will remain HIGH to show that the
// operation is still active.  Cleared automatically when STAT_RESUMEWAIT is set and the RESUMECMD bit is written to '1', meaning that the SW continues the operation of the channel.
// Note that each DMA channel can optionally have other sources of a pause request and this field will not reflect the state of the other sources.
// The DMA Unit level ALLCHPAUSE request is also not reflected by this bit.
//
void AdaPause(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_PAUSECMD_Msk;
}

//
// Dma Resume a Channel operation
// Resume Current DMA Operation. Writing this bit to '1' means that the SW can continue the operation of a paused channel.
// Can be set to '1' when the PAUSECMD or a STAT_DONE assertion with DONEPAUSEEN set HIGH results in pausing the current DMA channel operation
// indicated by the STAT_PAUSED and STAT_RESUMEWAIT bits. Otherwise, writes to this bit are ignored. Always read as 0.
//
void AdaResume(uint32_t ch_num, uint8_t security)
{
  DMACH_TypeDef * actual_frame;
  actual_frame = GetChannelPtr(ch_num, security);

  actual_frame->CH_CMD = (actual_frame->CH_CMD) | DMA_CH_CMD_RESUMECMD_Msk;
}

//
// Set 1D Command registers
//
//

void Ada1DCommand(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_XSIZE_Type CHXSIZE;
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Write whole registers
  actual_frame->CH_SRCADDR = (uint32_t)command_params.SRCADDR;
  actual_frame->CH_DESADDR = (uint32_t)command_params.DESADDR;

  //Read registers
  CHCTRL.w  = actual_frame->CH_CTRL;
  CHXSIZE.w = actual_frame->CH_XSIZE;

  //Modify registers
  CHCTRL.b.TRANSIZE  = command_params.TRANSIZE;
  // 0xFFFF is a bitmask, because the width of the SRC/DESXSIZE fields are 16 bit
  CHXSIZE.b.SRCXSIZE = (0xFFFF & command_params.SRCXSIZE);
  CHXSIZE.b.DESXSIZE = (0xFFFF & command_params.DESXSIZE);

  //Write registers
  actual_frame->CH_XSIZE = CHXSIZE.w;
  actual_frame->CH_CTRL  = CHCTRL.w;
}

uint32_t GetAdaActualSrcXSize(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_XSIZE_Type CHXSIZE;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHXSIZE.w = actual_frame->CH_XSIZE;

  //Modify registers
  return CHXSIZE.b.SRCXSIZE;
}
uint32_t GetAdaActualDesXSize(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_XSIZE_Type CHXSIZE;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHXSIZE.w = actual_frame->CH_XSIZE;

  //Modify registers
  return CHXSIZE.b.DESXSIZE;
}

void SetAdaLong1DRegs(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_XSIZEHI_Type CHXSIZEHI;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Write whole registers
  actual_frame->CH_SRCADDRHI = (command_params.SRCADDR >> 32);
  actual_frame->CH_DESADDRHI = (command_params.DESADDR >> 32);

  //Read registers
  CHXSIZEHI.w = actual_frame->CH_XSIZEHI;

  //Modify registers
  CHXSIZEHI.b.SRCXSIZEHI = (command_params.SRCXSIZE >> 16);
  CHXSIZEHI.b.SRCXSIZEHI = (command_params.SRCXSIZE >> 16);

  //Write registers
  actual_frame->CH_XSIZEHI = CHXSIZEHI.w;
}


void AdaLong1DCommand(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security)
{
  //Call the Short 1D command
  Ada1DCommand(command_params, ch_num, security);
  //Write HI registers
  SetAdaLong1DRegs(command_params, ch_num, security);
}


void AdaSetSrcTranAttrs(AdaChannelSrcAttrType src_attr, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_SRCTRANSCFG_Type CHSRCTRANSCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHSRCTRANSCFG.w = actual_frame->CH_SRCTRANSCFG;

  //Modify values
  CHSRCTRANSCFG.b.SRCMEMATTRLO  = src_attr.SRCMEMATTRLO;
  CHSRCTRANSCFG.b.SRCMEMATTRHI  = src_attr.SRCMEMATTRHI;
  CHSRCTRANSCFG.b.SRCSHAREATTR  = src_attr.SRCSHAREATTR;
  CHSRCTRANSCFG.b.SRCNONSECATTR = src_attr.SRCNONSECATTR;
  CHSRCTRANSCFG.b.SRCPRIVATTR   = src_attr.SRCPRIVATTR;

  //Write register
  actual_frame->CH_SRCTRANSCFG = CHSRCTRANSCFG.w ;
}

void AdaSetDesTranAttrs(AdaChannelDesAttrType des_attr, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_DESTRANSCFG_Type CHDESTRANSCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHDESTRANSCFG.w = actual_frame->CH_DESTRANSCFG;

  //Modify values
  CHDESTRANSCFG.b.DESMEMATTRLO  = des_attr.DESMEMATTRLO;
  CHDESTRANSCFG.b.DESMEMATTRHI  = des_attr.DESMEMATTRHI;
  CHDESTRANSCFG.b.DESSHAREATTR  = des_attr.DESSHAREATTR;
  CHDESTRANSCFG.b.DESNONSECATTR = des_attr.DESNONSECATTR;
  CHDESTRANSCFG.b.DESPRIVATTR   = des_attr.DESPRIVATTR;

  actual_frame->CH_DESTRANSCFG = CHDESTRANSCFG.w ;
}

//Set the basic settings of a DMA channel: CHPRIO, REGRELOADTYPE
void AdaChannelSettings(AdaChannelSettingsType ch_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;
  volatile DMACH_CH_CTRL_Type CHCTRL;
  volatile DMACH_CH_SRCTRANSCFG_Type CHSRCTRANSCFG;
  volatile DMACH_CH_DESTRANSCFG_Type CHDESTRANSCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCTRL.w        = actual_frame->CH_CTRL;
  CHCMD.w         = actual_frame->CH_CMD;
  CHSRCTRANSCFG.w = actual_frame->CH_SRCTRANSCFG;
  CHDESTRANSCFG.w = actual_frame->CH_DESTRANSCFG;

  //Modify values
  CHCTRL.b.CHPRIO                = ch_params.CHPRIO;
  CHCTRL.b.REGRELOADTYPE         = ch_params.REGRELOADTYPE;
  CHCTRL.b.DONETYPE              = ch_params.DONETYPE;
  CHCTRL.b.DONEPAUSEEN           = ch_params.DONEPAUSEEN;
  CHCMD.b.CLEARCMD               = ch_params.CLEARCMD;
  CHSRCTRANSCFG.b.SRCMAXBURSTLEN = ch_params.SRCMAXBURSTLEN;
  CHDESTRANSCFG.b.DESMAXBURSTLEN = ch_params.DESMAXBURSTLEN;

  //Write registers
  actual_frame->CH_CTRL        = CHCTRL.w;
  actual_frame->CH_CMD         = CHCMD.w;
  actual_frame->CH_SRCTRANSCFG = CHSRCTRANSCFG.w;
  actual_frame->CH_DESTRANSCFG = CHDESTRANSCFG.w;
}

//Set the basic settings of a DMA channel
void AdaChannelInit(AdaChannelSettingsType ch_params, AdaChannelSrcAttrType src_attr, AdaChannelDesAttrType des_attr, uint32_t ch_num, uint8_t security)
{
  AdaChannelSettings(ch_params, ch_num, security);
  AdaSetSrcTranAttrs(src_attr, ch_num, security);
  AdaSetDesTranAttrs(des_attr, ch_num, security);
}

void SetAda1DIncrRegs(Ada1DIncrCommandType incr_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_XADDRINC_Type CHXADDRINC;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHXADDRINC.w = actual_frame->CH_XADDRINC;

  //Modify registers
  CHXADDRINC.b.SRCXADDRINC = incr_params.SRCXADDRINC;
  CHXADDRINC.b.DESXADDRINC = incr_params.DESXADDRINC;

  //Write registers
  actual_frame->CH_XADDRINC = CHXADDRINC.w;
}

void Ada1DIncrCommand(AdaBaseCommandType command_params, Ada1DIncrCommandType incr_params, uint32_t ch_num, uint8_t security)
{
  Ada1DCommand(command_params, ch_num, security);
  SetAda1DIncrRegs(incr_params, ch_num, security);
}


void SetAda2DRegs(Ada2DCommandType y_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_YSIZE_Type YSIZE;
  volatile DMACH_CH_YADDRSTRIDE_Type YADDRSTRIDE;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  YSIZE.w       = actual_frame->CH_YSIZE;
  YADDRSTRIDE.w = actual_frame->CH_YADDRSTRIDE;

  //Modify registers
  YSIZE.b.SRCYSIZE             = y_params.SRCYSIZE;
  YSIZE.b.DESYSIZE             = y_params.DESYSIZE;
  YADDRSTRIDE.b.SRCYADDRSTRIDE = y_params.SRCYADDRSTRIDE;
  YADDRSTRIDE.b.DESYADDRSTRIDE = y_params.DESYADDRSTRIDE;

  //Write registers
  actual_frame->CH_YSIZE = YSIZE.w;
  actual_frame->CH_YADDRSTRIDE = YADDRSTRIDE.w;
}

void Ada2DCommand(AdaBaseCommandType command_params, Ada2DCommandType y_params, uint32_t ch_num, uint8_t security)
{
  Ada1DCommand(command_params, ch_num, security);
  SetAda2DRegs(y_params, ch_num, security);
}


void SetAdaWrapRegs(AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;

  //Modify registers
  CHCTRL.b.XTYPE   = wrap_params.XTYPE;
  CHCTRL.b.YTYPE   = wrap_params.YTYPE;

  //Write registers
  actual_frame->CH_CTRL    = CHCTRL.w;
  actual_frame->CH_FILLVAL = wrap_params.FILLVAL;
}

void AdaWrapCommand(AdaBaseCommandType command_params, AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security)
{
  Ada1DCommand(command_params, ch_num, security);
  SetAdaWrapRegs(wrap_params, ch_num, security);
}

void AdaWrap2DCommand(AdaBaseCommandType command_params, Ada2DCommandType y_params, AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security)
{
  Ada1DCommand(command_params, ch_num, security);
  SetAda2DRegs(y_params, ch_num, security);
  SetAdaWrapRegs(wrap_params, ch_num, security);
}


void SetAdaTmpltRegs(AdaTMPLTCommandType tmplt_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_TMPLTCFG_Type TMPLTCFG;
  volatile DMACH_CH_SRCTMPLT_Type SRCTMPLT;
  volatile DMACH_CH_DESTMPLT_Type DESTMPLT;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  TMPLTCFG.w = actual_frame->CH_TMPLTCFG;

  //Modify registers
  TMPLTCFG.b.SRCTMPLTSIZE = tmplt_params.SRCTMPLTSIZE;
  TMPLTCFG.b.DESTMPLTSIZE = tmplt_params.DESTMPLTSIZE;

  SRCTMPLT.b.SRCTMPLT    = (tmplt_params.SRCTMPLT >> 1);
  DESTMPLT.b.DESTMPLT    = (tmplt_params.DESTMPLT >> 1);

  //Write registers
  actual_frame->CH_TMPLTCFG = TMPLTCFG.w;
  actual_frame->CH_SRCTMPLT = SRCTMPLT.w;
  actual_frame->CH_DESTMPLT = DESTMPLT.w;
}

void AdaTmpltCommand(AdaBaseCommandType command_params, AdaTMPLTCommandType tmplt_params, uint32_t ch_num, uint8_t security)
{
  Ada1DCommand(command_params, ch_num, security);
  SetAdaTmpltRegs( tmplt_params, ch_num, security);
}

AdaStatType AdaReadStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;
  AdaStatType actual_stat;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set the Actual status to the struct
  actual_stat.STAT_DONE       = STATUS.b.STAT_DONE;
  actual_stat.STAT_ERR        = STATUS.b.STAT_ERR;
  actual_stat.STAT_DISABLED   = STATUS.b.STAT_DISABLED;
  actual_stat.STAT_STOPPED    = STATUS.b.STAT_STOPPED;
  actual_stat.STAT_PAUSED     = STATUS.b.STAT_PAUSED;
  actual_stat.STAT_RESUMEWAIT = STATUS.b.STAT_RESUMEWAIT;

  return actual_stat;
}

uint8_t AdaChDoneStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_DONE;
}

uint8_t AdaChErrorStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_ERR;
}

uint8_t AdaChDisabledStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_DISABLED;
}

uint8_t AdaChStoppedStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_STOPPED;
}

uint8_t AdaChPausedStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_PAUSED;
}

uint8_t AdaChResumeWaitStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_RESUMEWAIT;
}

void AdaClearChDone(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set W1C register to 1
  STATUS.b.STAT_DONE     = 1;
  // Set other W1C registers to 0 (avoid clearing)
  STATUS.b.STAT_ERR      = 0;
  STATUS.b.STAT_DISABLED = 0;
  STATUS.b.STAT_STOPPED  = 0;

  //Wite register
  actual_frame->CH_STATUS = STATUS.w;
}

void AdaClearChError(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set W1C register to 1
  STATUS.b.STAT_ERR      = 1;
  // Set other W1C registers to 0 (avoid clearing)
  STATUS.b.STAT_DONE     = 0;
  STATUS.b.STAT_DISABLED = 0;
  STATUS.b.STAT_STOPPED  = 0;

  //Wite register
  actual_frame->CH_STATUS = STATUS.w;
}

void AdaClearChDisabled(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set W1C register to 1
  STATUS.b.STAT_DISABLED = 1;
  // Set other W1C registers to 0 (avoid clearing)
  STATUS.b.STAT_DONE     = 0;
  STATUS.b.STAT_ERR      = 0;
  STATUS.b.STAT_STOPPED  = 0;

  //Wite register
  actual_frame->CH_STATUS = STATUS.w;
}

void AdaClearChStopped(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set W1C register to 1
  STATUS.b.STAT_STOPPED  = 1;
  // Set other W1C registers to 0 (avoid clearing)
  STATUS.b.STAT_DONE     = 0;
  STATUS.b.STAT_ERR      = 0;
  STATUS.b.STAT_DISABLED = 0;

  //Wite register
  actual_frame->CH_STATUS = STATUS.w;
}

void AdaClearAllChIrq(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set W1C register to 1
  STATUS.b.STAT_STOPPED  = 1;
  STATUS.b.STAT_DONE     = 1;
  STATUS.b.STAT_ERR      = 1;
  STATUS.b.STAT_DISABLED = 1;

  //Wite register
  actual_frame->CH_STATUS = STATUS.w;
}

AdaTrigStatType AdaReadTrigStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;
  AdaTrigStatType actual_trig_stat;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set the Actual status to the struct
  actual_trig_stat.STAT_SRCTRIGINWAIT  = STATUS.b.STAT_SRCTRIGINWAIT;
  actual_trig_stat.STAT_DESTRIGINWAIT  = STATUS.b.STAT_DESTRIGINWAIT;
  actual_trig_stat.STAT_TRIGOUTACKWAIT = STATUS.b.STAT_TRIGOUTACKWAIT;

  return actual_trig_stat;
}

uint8_t AdaChSrcTrigInWaitStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_SRCTRIGINWAIT;
}

uint8_t AdaChDesTrigInWaitStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_DESTRIGINWAIT;
}

uint8_t AdaChTrigOutAckWaitStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Return actual status
  return STATUS.b.STAT_TRIGOUTACKWAIT;
}


AdaIrqType AdaReadIrqStatus(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STATUS_Type STATUS;
  AdaIrqType actual_irq_stat;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  STATUS.w = actual_frame->CH_STATUS;

  // Set the Actual status to the struct
  actual_irq_stat.INTR_DONE           = STATUS.b.INTR_DONE;
  actual_irq_stat.INTR_ERR            = STATUS.b.INTR_ERR;
  actual_irq_stat.INTR_DISABLED       = STATUS.b.INTR_DISABLED;
  actual_irq_stat.INTR_STOPPED        = STATUS.b.INTR_STOPPED;
  actual_irq_stat.INTR_SRCTRIGINWAIT  = STATUS.b.INTR_SRCTRIGINWAIT;
  actual_irq_stat.INTR_DESTRIGINWAIT  = STATUS.b.INTR_DESTRIGINWAIT;
  actual_irq_stat.INTR_TRIGOUTACKWAIT = STATUS.b.INTR_TRIGOUTACKWAIT;

  return actual_irq_stat;
}

void AdaSetIntEn(AdaIrqEnType int_en_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_DONE     = int_en_params.INTREN_DONE;
  INTREN.b.INTREN_ERR      = int_en_params.INTREN_ERR;
  INTREN.b.INTREN_DISABLED = int_en_params.INTREN_DISABLED;
  INTREN.b.INTREN_STOPPED  = int_en_params.INTREN_STOPPED;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetDoneIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_DONE = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetErrorIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_ERR = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetDisabledIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_DISABLED = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetStoppedIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_STOPPED = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetTrigIntEn(AdaTrigIrqEnType trig_int_en_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_SRCTRIGINWAIT  = trig_int_en_params.INTREN_SRCTRIGINWAIT;
  INTREN.b.INTREN_DESTRIGINWAIT  = trig_int_en_params.INTREN_DESTRIGINWAIT;
  INTREN.b.INTREN_TRIGOUTACKWAIT = trig_int_en_params.INTREN_TRIGOUTACKWAIT;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetSrcTrigInWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_SRCTRIGINWAIT = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetDestTrigInWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_DESTRIGINWAIT = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

void AdaSetTrigOutAckWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_INTREN_Type INTREN;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  INTREN.w = actual_frame->CH_INTREN;

  //Modify registers
  INTREN.b.INTREN_TRIGOUTACKWAIT = en;

  //Write registers
  actual_frame->CH_INTREN = INTREN.w;
}

AdaErrInfoType AdaReadErrorInfo(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_ERRINFO_Type ERRINFO;
  AdaErrInfoType actual_error_info;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  ERRINFO.w = actual_frame->CH_ERRINFO;

  // Set the Actual status to the struct
  actual_error_info.BUSERR          = ERRINFO.b.BUSERR;
  actual_error_info.CFGERR          = ERRINFO.b.CFGERR;
  actual_error_info.SRCTRIGINSELERR = ERRINFO.b.SRCTRIGINSELERR;
  actual_error_info.DESTRIGINSELERR = ERRINFO.b.DESTRIGINSELERR;
  actual_error_info.TRIGOUTSELERR   = ERRINFO.b.TRIGOUTSELERR;
  actual_error_info.STREAMERR     = ERRINFO.b.STREAMERR;
  actual_error_info.ERRINFO         = ERRINFO.b.ERRINFO;

  return actual_error_info;
}

AdaSwTrigInType AdaSrcSwTigInState(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Trigger state struct
  AdaSwTrigInType sw_trigin_state;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Get values
  sw_trigin_state.SWTRIGINREQ  = CHCMD.b.SRCSWTRIGINREQ;
  sw_trigin_state.SWTRIGINTYPE = CHCMD.b.SRCSWTRIGINTYPE;

  //Return state
  return sw_trigin_state;
}

AdaSwTrigInType AdaDesSwTigInState(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Trigger state struct
  AdaSwTrigInType sw_trigin_state;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Get values
  sw_trigin_state.SWTRIGINREQ  = CHCMD.b.DESSWTRIGINREQ;
  sw_trigin_state.SWTRIGINTYPE = CHCMD.b.DESSWTRIGINTYPE;

  //Return state
  return sw_trigin_state;
}


uint8_t AdaSwTrigOutState(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Return state
  return CHCMD.b.SWTRIGOUTACK;
}

void AdaDesSwTrigInReq(AdaSwTriggerType_t trigin_type, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Set values
  CHCMD.b.DESSWTRIGINREQ = 1;
  CHCMD.b.DESSWTRIGINTYPE = trigin_type;
  //Set W1S fields to 0
  CHCMD.b.ENABLECMD      = 0;
  CHCMD.b.CLEARCMD       = 0;
  CHCMD.b.DISABLECMD     = 0;
  CHCMD.b.STOPCMD        = 0;
  CHCMD.b.PAUSECMD       = 0;
  CHCMD.b.RESUMECMD      = 0;
  CHCMD.b.SRCSWTRIGINREQ = 0;
  CHCMD.b.SWTRIGOUTACK   = 0;

  actual_frame->CH_CMD = CHCMD.w;
}

void AdaSrcSwTrigInReq(AdaSwTriggerType_t trigin_type, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Set values
  CHCMD.b.SRCSWTRIGINREQ = 1;
  CHCMD.b.SRCSWTRIGINTYPE = trigin_type;
  //Set W1S fields to 0
  CHCMD.b.ENABLECMD      = 0;
  CHCMD.b.CLEARCMD       = 0;
  CHCMD.b.DISABLECMD     = 0;
  CHCMD.b.STOPCMD        = 0;
  CHCMD.b.PAUSECMD       = 0;
  CHCMD.b.RESUMECMD      = 0;
  CHCMD.b.DESSWTRIGINREQ = 0;
  CHCMD.b.SWTRIGOUTACK   = 0;

  actual_frame->CH_CMD = CHCMD.w;
}

void AdaSwTrigOutAck(uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CMD_Type CHCMD;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHCMD.w = actual_frame->CH_CMD;

  //Set values
  CHCMD.b.SWTRIGOUTACK   = 1;
  //Set W1S fields to 0
  CHCMD.b.ENABLECMD      = 0;
  CHCMD.b.CLEARCMD       = 0;
  CHCMD.b.DISABLECMD     = 0;
  CHCMD.b.STOPCMD        = 0;
  CHCMD.b.PAUSECMD       = 0;
  CHCMD.b.RESUMECMD      = 0;
  CHCMD.b.DESSWTRIGINREQ = 0;
  CHCMD.b.SRCSWTRIGINREQ = 0;

  actual_frame->CH_CMD = CHCMD.w;
}

void AdaSrcTrigInInit(AdaTrigInType src_trigin_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  DMACH_CH_SRCTRIGINCFG_Type SRCTRIGINCFG;
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;
  SRCTRIGINCFG.w = actual_frame->CH_SRCTRIGINCFG;

  //Modify registers
  CHCTRL.b.USESRCTRIGIN           = src_trigin_params.USETRIGIN;
  SRCTRIGINCFG.b.SRCTRIGINSEL     = src_trigin_params.TRIGINSEL;
  SRCTRIGINCFG.b.SRCTRIGINTYPE    = src_trigin_params.TRIGINTYPE;
  SRCTRIGINCFG.b.SRCTRIGINMODE    = src_trigin_params.TRIGINMODE;
  SRCTRIGINCFG.b.SRCTRIGINBLKSIZE = src_trigin_params.TRIGINBLKSIZE;

  //Write registers
  actual_frame->CH_SRCTRIGINCFG = SRCTRIGINCFG.w;
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaSrcTrigInEnable(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;

  //Modify registers
  CHCTRL.b.USESRCTRIGIN = en;

  //Write registers
  actual_frame->CH_CTRL = CHCTRL.w;
}


void AdaDesTrigInInit(AdaTrigInType des_trigin_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_DESTRIGINCFG_Type DESTRIGINCFG;
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;
  DESTRIGINCFG.w = actual_frame->CH_DESTRIGINCFG;

  //Modify registers
  CHCTRL.b.USEDESTRIGIN           = des_trigin_params.USETRIGIN;
  DESTRIGINCFG.b.DESTRIGINSEL     = des_trigin_params.TRIGINSEL;
  DESTRIGINCFG.b.DESTRIGINTYPE    = des_trigin_params.TRIGINTYPE;
  DESTRIGINCFG.b.DESTRIGINMODE    = des_trigin_params.TRIGINMODE;
  DESTRIGINCFG.b.DESTRIGINBLKSIZE = des_trigin_params.TRIGINBLKSIZE;

  //Write registers
  actual_frame->CH_DESTRIGINCFG = DESTRIGINCFG.w;
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaDesTrigInEnable(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;

  //Modify registers
  CHCTRL.b.USEDESTRIGIN = en;

  //Write registers
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaTrigOutInit(AdaTrigOutType trigout_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_TRIGOUTCFG_Type TRIGOUTCFG;
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;
  TRIGOUTCFG.w = actual_frame->CH_TRIGOUTCFG;

  //Modify registers
  CHCTRL.b.USETRIGOUT      = trigout_params.USETRIGOUT;
  TRIGOUTCFG.b.TRIGOUTSEL  = trigout_params.TRIGOUTSEL;
  TRIGOUTCFG.b.TRIGOUTTYPE = trigout_params.TRIGOUTTYPE;

  //Write registers
  actual_frame->CH_TRIGOUTCFG = TRIGOUTCFG.w;
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaTrigOutEnable(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;

  //Modify registers
  CHCTRL.b.USETRIGOUT = en;

  //Write registers
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaStreamInit(AdaStreamType stream_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_STREAMINTCFG_Type STREAMINTCFG;
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;
  STREAMINTCFG.w = actual_frame->CH_STREAMINTCFG;

  //Modify registers
  STREAMINTCFG.b.STREAMTYPE = stream_params.STREAMTYPE;

  //Write registers
  actual_frame->CH_STREAMINTCFG = STREAMINTCFG.w;
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaStreamEnable(uint8_t en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_CTRL_Type CHCTRL;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;

  //Modify registers
  CHCTRL.b.USESTREAM = en;

  //Write registers
  actual_frame->CH_CTRL = CHCTRL.w;
}

void AdaSetLinkTranAttrs(AdaChannelLinkAttrType link_attr, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_LINKATTR_Type CHLINKATTR;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHLINKATTR.w = actual_frame->CH_LINKATTR;

  //Modify values
  CHLINKATTR.b.LINKMEMATTRLO = link_attr.LINKMEMATTRLO;
  CHLINKATTR.b.LINKMEMATTRHI = link_attr.LINKMEMATTRHI;
  CHLINKATTR.b.LINKSHAREATTR = link_attr.LINKSHAREATTR;

  //Write register
  actual_frame->CH_LINKATTR = CHLINKATTR.w ;
}

void AdaSetCmdLink(AdaCmdLinkType cmd_link_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_LINKADDR_Type LINKADDR;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  LINKADDR.w = actual_frame->CH_LINKADDR;

  //Modify registers
  LINKADDR.b.LINKADDREN = cmd_link_params.LINKADDREN;
  LINKADDR.b.LINKADDR = (uint32_t)(0x3FFFFFFF & (cmd_link_params.LINKADDR >> 2));

  //Write registers
  actual_frame->CH_LINKADDR   = LINKADDR.w;
  actual_frame->CH_LINKADDRHI = (uint32_t)(cmd_link_params.LINKADDR >> 32);
}

uint8_t AdaGetLinkTranMemAttrs(uint32_t ch_num, uint8_t security)
{
  uint8_t return_value;
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_LINKATTR_Type CHLINKATTR;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHLINKATTR.w = actual_frame->CH_LINKATTR;

  //Return value
  return_value = (CHLINKATTR.b.LINKMEMATTRHI<<4) & CHLINKATTR.b.LINKMEMATTRLO;
  return return_value;
}

uint8_t AdaGetLinkTranShareAttrs(uint32_t ch_num, uint8_t security)
{
  uint8_t return_value;
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_LINKATTR_Type CHLINKATTR;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read register
  CHLINKATTR.w = actual_frame->CH_LINKATTR;

  //Return value
  return_value = CHLINKATTR.b.LINKSHAREATTR;
  return return_value;
}

uint64_t AdaGetCmdLinkAddr(uint32_t ch_num, uint8_t security)
{
  uint64_t return_value=0;
  //Temporary unions for register read-write
  volatile DMACH_CH_LINKADDR_Type CHLINKADDR;
  volatile DMACH_CH_LINKADDRHI_Type CHLINKADDRHI;
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  CHLINKADDR.w = actual_frame->CH_LINKADDR;
  CHLINKADDRHI.w = actual_frame->CH_LINKADDRHI;

  // Return address
  return_value = CHLINKADDRHI.b.LINKADDRHI;
  return_value = (return_value<<32 ) | (CHLINKADDR.b.LINKADDR<<2);
  return return_value;
}


void AdaAutoRestart(AdaAutoRestartType restart_params, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_AUTOCFG_Type AUTOCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  AUTOCFG.w = actual_frame->CH_AUTOCFG;

  //Modify registers
  AUTOCFG.b.CMDRESTARTCNT   = restart_params.CMDRESTARTCNT;
  AUTOCFG.b.CMDRESTARTINFEN = restart_params.CMDRESTARTINFEN;

  //Write registers
  actual_frame->CH_AUTOCFG = AUTOCFG.w;
}

void AdaSetRestartCntr(uint16_t restartcnt, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_AUTOCFG_Type AUTOCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  AUTOCFG.w = actual_frame->CH_AUTOCFG;

  //Modify registers
  AUTOCFG.b.CMDRESTARTCNT = restartcnt;

  //Write registers
  actual_frame->CH_AUTOCFG = AUTOCFG.w;
}

void AdaInfRestart(uint8_t inf_restart_en, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_AUTOCFG_Type AUTOCFG;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  AUTOCFG.w = actual_frame->CH_AUTOCFG;

  //Modify registers
  AUTOCFG.b.CMDRESTARTINFEN = inf_restart_en;

  //Write registers
  actual_frame->CH_AUTOCFG = AUTOCFG.w;
}

void AdaSetGPO(uint64_t gpo_value, uint32_t width, uint32_t ch_num, uint8_t security)
{
  //Pointer for the actual channel
  DMACH_TypeDef * actual_frame;
  //Temporary unions for register read-write
  volatile DMACH_CH_GPOEN0_Type GPOEN0;
  volatile DMACH_CH_GPOVAL0_Type GPOVAL0;
  volatile DMACH_CH_CTRL_Type CHCTRL;
  // Enable mask
  uint32_t en_mask = 0;

  //Get the actual channel frame
  actual_frame = GetChannelPtr(ch_num, security);

  //Read registers
  CHCTRL.w = actual_frame->CH_CTRL;
  GPOEN0.w = actual_frame->CH_GPOEN0;
  GPOVAL0.w = actual_frame->CH_GPOVAL0;

  //Modify registers
  if(width<32){
    for(int i = 0; i<width; i++){
      en_mask = (en_mask<<1)+1;
    }
    GPOEN0.b.GPOEN0 = en_mask;
  }
  else{
    GPOEN0.b.GPOEN0 = 0xFFFFFFFF;
  }

  GPOVAL0.b.GPOVAL0 = (0xFFFFFFFF & gpo_value);

  CHCTRL.b.USEGPO = 1;


  //Write registers
  actual_frame->CH_GPOEN0 = GPOEN0.w;
  actual_frame->CH_GPOVAL0 = GPOVAL0.w;
  actual_frame->CH_CTRL = CHCTRL.w;
}

uint32_t GetNonSecCollIrqStat(void)
{
  return DMANSECCTRL_NS->NSEC_CHINTRSTATUS0;
}
uint32_t GetSecCollIrqStat(void)
{
  return DMASECCTRL_S->SEC_CHINTRSTATUS0;
}

AdaCombIrqType AdaReadNSecCombIrqStatus(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;
  AdaCombIrqType actual_irq_stat;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  actual_irq_stat.INTR_ANYCHINTR    = STATUS.b.INTR_ANYCHINTR;
  actual_irq_stat.INTR_ALLCHIDLE    = STATUS.b.INTR_ALLCHIDLE;
  actual_irq_stat.INTR_ALLCHSTOPPED = STATUS.b.INTR_ALLCHSTOPPED;
  actual_irq_stat.INTR_ALLCHPAUSED  = STATUS.b.INTR_ALLCHPAUSED;

  return actual_irq_stat;
}
AdaCombIrqType AdaReadSecCombIrqStatus(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;
  AdaCombIrqType actual_irq_stat;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  actual_irq_stat.INTR_ANYCHINTR    = STATUS.b.INTR_ANYCHINTR;
  actual_irq_stat.INTR_ALLCHIDLE    = STATUS.b.INTR_ALLCHIDLE;
  actual_irq_stat.INTR_ALLCHSTOPPED = STATUS.b.INTR_ALLCHSTOPPED;
  actual_irq_stat.INTR_ALLCHPAUSED  = STATUS.b.INTR_ALLCHPAUSED;

  return actual_irq_stat;
}

uint8_t AdaNSecCombinedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ANYCHINTR;
}

uint8_t AdaSecCombinedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ANYCHINTR;
}

uint8_t AdaNSecAllIdleIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHIDLE;
}

uint8_t AdaSecAllIdleIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHIDLE;
}

uint8_t AdaNSecAllStoppedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHSTOPPED;
}

uint8_t AdaSecAllStoppedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHSTOPPED;
}

uint8_t AdaNSecAllPausedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHPAUSED;
}

uint8_t AdaSecAllPausedIrqState(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.INTR_ALLCHPAUSED;
}

AdaCombIrqClrType AdaReadSecCombStatus(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;
  AdaCombIrqClrType actual_stat;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  actual_stat.STAT_ALLCHIDLE    = STATUS.b.STAT_ALLCHIDLE;
  actual_stat.STAT_ALLCHSTOPPED = STATUS.b.STAT_ALLCHSTOPPED;
  actual_stat.STAT_ALLCHPAUSED  = STATUS.b.STAT_ALLCHPAUSED;

  return actual_stat;
}

AdaCombIrqClrType AdaReadNSecCombStatus(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;
  AdaCombIrqClrType actual_stat;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  actual_stat.STAT_ALLCHIDLE    = STATUS.b.STAT_ALLCHIDLE;
  actual_stat.STAT_ALLCHSTOPPED = STATUS.b.STAT_ALLCHSTOPPED;
  actual_stat.STAT_ALLCHPAUSED  = STATUS.b.STAT_ALLCHPAUSED;

  return actual_stat;
}

void AdaClrSecCombIrq(AdaCombIrqClrType clr_state)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = clr_state.STAT_ALLCHIDLE;
  STATUS.b.STAT_ALLCHSTOPPED = clr_state.STAT_ALLCHSTOPPED;
  STATUS.b.STAT_ALLCHPAUSED  = clr_state.STAT_ALLCHPAUSED;

  DMASECCTRL_S->SEC_STATUS = STATUS.w;
}

void AdaClrNSecCombIrq(AdaCombIrqClrType clr_state)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = clr_state.STAT_ALLCHIDLE;
  STATUS.b.STAT_ALLCHSTOPPED = clr_state.STAT_ALLCHSTOPPED;
  STATUS.b.STAT_ALLCHPAUSED  = clr_state.STAT_ALLCHPAUSED;

  DMANSECCTRL_NS->NSEC_STATUS = STATUS.w;
}

void AdaClrSecAllChIdleIrq(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 1;
  STATUS.b.STAT_ALLCHSTOPPED = 0;
  STATUS.b.STAT_ALLCHPAUSED  = 0;

  DMASECCTRL_S->SEC_STATUS = STATUS.w;
}

void AdaClrNSecAllChIdleIrq(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 1;
  STATUS.b.STAT_ALLCHSTOPPED = 0;
  STATUS.b.STAT_ALLCHPAUSED  = 0;

  DMANSECCTRL_NS->NSEC_STATUS = STATUS.w;
}

void AdaClrSecAllChStoppedIrq(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 0;
  STATUS.b.STAT_ALLCHSTOPPED = 1;
  STATUS.b.STAT_ALLCHPAUSED  = 0;

  DMASECCTRL_S->SEC_STATUS = STATUS.w;
}

void AdaClrNSecAllChStoppedIrq(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 0;
  STATUS.b.STAT_ALLCHSTOPPED = 1;
  STATUS.b.STAT_ALLCHPAUSED  = 0;

  DMANSECCTRL_NS->NSEC_STATUS = STATUS.w;
}

void AdaClrSecAllChPausedIrq(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 0;
  STATUS.b.STAT_ALLCHSTOPPED = 0;
  STATUS.b.STAT_ALLCHPAUSED  = 1;

  DMASECCTRL_S->SEC_STATUS = STATUS.w;
}

void AdaClrNSecAllChPausedIrq(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Set the Actual status to the struct
  STATUS.b.STAT_ALLCHIDLE    = 0;
  STATUS.b.STAT_ALLCHSTOPPED = 0;
  STATUS.b.STAT_ALLCHPAUSED  = 1;

  DMANSECCTRL_NS->NSEC_STATUS = STATUS.w;
}

void AdaSecCombIrqEn(AdaCombIrqEnType irq_en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR    = irq_en.INTREN_ANYCHINTR;
  CTRL.b.INTREN_ALLCHIDLE    = irq_en.INTREN_ALLCHIDLE;
  CTRL.b.INTREN_ALLCHSTOPPED = irq_en.INTREN_ALLCHSTOPPED;
  CTRL.b.INTREN_ALLCHPAUSED  = irq_en.INTREN_ALLCHPAUSED;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecCombIrqEn(AdaCombIrqEnType irq_en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR    = irq_en.INTREN_ANYCHINTR;
  CTRL.b.INTREN_ALLCHIDLE    = irq_en.INTREN_ALLCHIDLE;
  CTRL.b.INTREN_ALLCHSTOPPED = irq_en.INTREN_ALLCHSTOPPED;
  CTRL.b.INTREN_ALLCHPAUSED  = irq_en.INTREN_ALLCHPAUSED;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecCombCtrlIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR =   irq_en;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecCombCtrlIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR =   irq_en;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecAllChIdleIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHIDLE =   irq_en;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecAllChIdleIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHIDLE =   irq_en;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecAllChStoppedIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHSTOPPED =   irq_en;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecAllChStoppedIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHSTOPPED =   irq_en;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecAllChPausedIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHPAUSED =   irq_en;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecAllChPausedIrqEn(uint8_t irq_en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ALLCHPAUSED =   irq_en;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}


void AdaSecIrqCombine(uint8_t en)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR =   en;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecIrqCombine(uint8_t en)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.INTREN_ANYCHINTR =   en;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecAllChStopReq(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.ALLCHSTOP =   1;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecAllChStopReq(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.ALLCHSTOP =   1;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecAllChPauseReq(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.ALLCHPAUSE =   1;

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecAllChPauseReq(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.ALLCHPAUSE =   1;

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecDisMinPwr(uint8_t dis_min_pwr)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMASECCTRL_S->SEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.DISMINPWR =   (3 & dis_min_pwr);

  DMASECCTRL_S->SEC_CTRL = CTRL.w;
}

void AdaNSecDisMinPwr(uint8_t dis_min_pwr)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CTRL_Type CTRL;

  //Read registers
  CTRL.w = DMANSECCTRL_NS->NSEC_CTRL;

  // Set the Actual status to the struct
  CTRL.b.DISMINPWR =   (3 & dis_min_pwr);

  DMANSECCTRL_NS->NSEC_CTRL = CTRL.w;
}

void AdaSecSetChParams(AdaCombChCfgType ch_params)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_CHCFG_Type CHCFG;
  volatile DMASECCTRL_SEC_CHPTR_Type CHPTR;

  //Read registers
  CHCFG.w = DMASECCTRL_S->SEC_CHCFG;
  CHPTR.w = DMASECCTRL_S->SEC_CHPTR;

  // Set the Actual status to the struct
  CHPTR.b.CHPTR   = ch_params.CHPTR;
  CHCFG.b.CHID    = ch_params.CHID;
  CHCFG.b.CHIDVLD = ch_params.CHIDVLD;
  CHCFG.b.CHPRIV  = ch_params.CHPRIV;

  DMASECCTRL_S->SEC_CHPTR = CHPTR.w;
  DMASECCTRL_S->SEC_CHCFG = CHCFG.w;
}

void AdaNSecSetChParams(AdaCombChCfgType ch_params)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_CHCFG_Type CHCFG;
  volatile DMANSECCTRL_NSEC_CHPTR_Type CHPTR;

  //Read registers
  CHCFG.w = DMANSECCTRL_NS->NSEC_CHCFG;
  CHPTR.w = DMANSECCTRL_NS->NSEC_CHPTR;

  // Set the Actual status to the struct
  CHPTR.b.CHPTR   = ch_params.CHPTR;
  CHCFG.b.CHID    = ch_params.CHID;
  CHCFG.b.CHIDVLD = ch_params.CHIDVLD;
  CHCFG.b.CHPRIV  = ch_params.CHPRIV;

  DMANSECCTRL_NS->NSEC_CHPTR = CHPTR.w;
  DMANSECCTRL_NS->NSEC_CHCFG = CHCFG.w;
}

void AdaSecSetChPtr(uint8_t ch)
{
  //Temporary unions for register read-write
    volatile DMASECCTRL_SEC_CHPTR_Type CHPTR;

  //Read registers
    CHPTR.w = DMASECCTRL_S->SEC_CHPTR;

  // Set the Actual channel pointer
    CHPTR.b.CHPTR =   ch;

    DMASECCTRL_S->SEC_CHPTR = CHPTR.w;
}

void AdaNSecSetChPtr(uint8_t ch)
{
  //Temporary unions for register read-write
    volatile DMANSECCTRL_NSEC_CHPTR_Type CHPTR;

  //Read registers
    CHPTR.w = DMANSECCTRL_NS->NSEC_CHPTR;

  // Set the Actual channel pointer
    CHPTR.b.CHPTR =   ch;

    DMANSECCTRL_NS->NSEC_CHPTR = CHPTR.w;
}

void AdaSecSetChId(uint8_t ch, uint16_t chid)
{
  //Temporary unions for register read-write
    volatile DMASECCTRL_SEC_CHCFG_Type CHCFG;
    // Set Channel pointer
    printf("Set Channel Pointer");
    AdaSecSetChPtr(ch);

    printf("Read Secure config");
    //Read registers
    CHCFG.w = DMASECCTRL_S->SEC_CHCFG;
    printf("Set CHID");

    // Set the Actual channel pointer
    CHCFG.b.CHID = chid;
    CHCFG.b.CHIDVLD = 1;

    DMASECCTRL_S->SEC_CHCFG = CHCFG.w;
}

void AdaNSecSetChId(uint8_t ch, uint16_t chid)
{
  //Temporary unions for register read-write
    volatile DMANSECCTRL_NSEC_CHCFG_Type CHCFG;

    // Set Channel pointer
    AdaNSecSetChPtr(ch);

    //Read registers
    CHCFG.w = DMANSECCTRL_NS->NSEC_CHCFG;

    // Set the Actual channel pointer
    CHCFG.b.CHID = chid;
    CHCFG.b.CHIDVLD = 1;

    DMANSECCTRL_NS->NSEC_CHCFG = CHCFG.w;
}

void AdaSecSetChPrivileged(uint8_t ch, uint8_t privileged)
{
  //Temporary unions for register read-write
    volatile DMASECCTRL_SEC_CHCFG_Type CHCFG;
    // Set Channel pointer
    AdaSecSetChPtr(ch);

    //Read registers
    CHCFG.w = DMASECCTRL_S->SEC_CHCFG;

    // Set the Actual channel pointer
    CHCFG.b.CHPRIV = privileged;

    DMASECCTRL_S->SEC_CHCFG = CHCFG.w;
}

void AdaNSecSetChPrivileged(uint8_t ch, uint8_t privileged)
{
  //Temporary unions for register read-write
    volatile DMANSECCTRL_NSEC_CHCFG_Type CHCFG;

    // Set Channel pointer
    AdaNSecSetChPtr(ch);

    //Read registers
    CHCFG.w = DMANSECCTRL_NS->NSEC_CHCFG;

    // Set the Actual channel pointer
    CHCFG.b.CHPRIV = privileged;

    DMANSECCTRL_NS->NSEC_CHCFG = CHCFG.w;
}

//Set channel Security Configuration
void AdaSetChSecMappig(uint32_t mapping)
{
  DMASECCFG_S->SCFG_CHSEC0 = mapping;
}

void AdaSetChSecurity(uint32_t ch_num, uint32_t security)
{
  volatile uint32_t actual_security;
  volatile uint32_t ch_mask;
  ch_mask = (1<<ch_num);
  actual_security = DMASECCFG_S->SCFG_CHSEC0;
  DMASECCFG_S->SCFG_CHSEC0 = (actual_security&(~ch_mask)) | ((security<<ch_num) & ch_mask);
}
void AdaSetTrigInSecMappig(uint32_t mapping)
{
  DMASECCFG_S->SCFG_TRIGINSEC0 = mapping;
}

void AdaSetTrigInSecurity(uint32_t trig_num, uint8_t security)
{
  uint32_t actual_security;
  uint32_t trig_mask;
  trig_mask = (1<<trig_num);
  actual_security = DMASECCFG_S->SCFG_TRIGINSEC0;
  DMASECCFG_S->SCFG_TRIGINSEC0 = (actual_security&(~trig_mask)) | ((security<<trig_num) & trig_mask);
}

void AdaSetTrigOutSecMappig(uint32_t mapping)
{
  DMASECCFG_S->SCFG_TRIGOUTSEC0 = mapping;
}

void AdaSetTrigOutSecurity(uint32_t trig_num, uint8_t security)
{
  uint32_t actual_security;
  uint32_t trig_mask;
  trig_mask = (1<<trig_num);
  actual_security = DMASECCFG_S->SCFG_TRIGOUTSEC0;
  DMASECCFG_S->SCFG_TRIGOUTSEC0 = (actual_security&(~trig_mask)) | ((security<<trig_num) & trig_mask);
}

void AdaSecViolationIrqEn(uint8_t en)
{
  //Temporary unions for register read-write
  volatile DMASECCFG_SCFG_CTRL_Type SCFG_CTRL;

  //Read registers
  SCFG_CTRL.w = DMASECCFG_S->SCFG_CTRL;

  // Set the Actual irq enable
  SCFG_CTRL.b.INTREN_SECACCVIO =   en;

  DMASECCFG_S->SCFG_CTRL = SCFG_CTRL.w;
}

void AdaSecViolationResp(uint8_t resp)
{
  //Temporary unions for register read-write
    volatile DMASECCFG_SCFG_CTRL_Type SCFG_CTRL;

  //Read registers
  SCFG_CTRL.w = DMASECCFG_S->SCFG_CTRL;

  // Set the Actual irq enable
  SCFG_CTRL.b.RSPTYPE_SECACCVIO =   resp;

  DMASECCFG_S->SCFG_CTRL = SCFG_CTRL.w;
}


void AdaSecConfigLock()
{
  //Temporary unions for register read-write
  volatile DMASECCFG_SCFG_CTRL_Type SCFG_CTRL;

  //Read registers
  SCFG_CTRL.w = DMASECCFG_S->SCFG_CTRL;

  // Lock Security config
  SCFG_CTRL.b.SEC_CFG_LCK =   1;

  DMASECCFG_S->SCFG_CTRL = SCFG_CTRL.w;
}

uint8_t AdaSecViolationIrqState(void)
{
  //Read registers
  return (1 & DMASECCFG_S->SCFG_INTRSTATUS);
}

void AdaClrSecViolationIrq(void)
{
  //Read registers
  DMASECCFG_S->SCFG_INTRSTATUS = 1;
}

uint8_t AdaNSecAllPausedState(void)
{
  //Temporary unions for register read-write
  volatile DMANSECCTRL_NSEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMANSECCTRL_NS->NSEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.STAT_ALLCHPAUSED;
}

uint8_t AdaSecAllPausedState(void)
{
  //Temporary unions for register read-write
  volatile DMASECCTRL_SEC_STATUS_Type STATUS;

  //Read registers
  STATUS.w = DMASECCTRL_S->SEC_STATUS;

  // Re the Actual status to the struct
  return STATUS.b.STAT_ALLCHPAUSED;
}


uint32_t AdaGetChNum(uint8_t security) {
  //Temporary unions for register read-write
  volatile DMAINFO_DMA_BUILDCFG0_Type info_bcfg;
  //Read registers
  if(security==0){
    info_bcfg.w = DMAINFO_S->DMA_BUILDCFG0;
  }
  else {
    info_bcfg.w = DMAINFO_NS->DMA_BUILDCFG0;
  }
  //Return number of channels
  return (info_bcfg.b.NUM_CHANNELS + 1);
}
uint32_t AdaGetTrigInNum(uint8_t security) {
  //Temporary unions for register read-write
  volatile DMAINFO_DMA_BUILDCFG1_Type info_bcfg;
  //Read registers
  if(security==0){
    info_bcfg.w = DMAINFO_S->DMA_BUILDCFG1;
  }
  else {
    info_bcfg.w = DMAINFO_NS->DMA_BUILDCFG1;
  }
  //Return number of trigger outputs
  return info_bcfg.b.NUM_TRIGGER_IN;
}
uint32_t AdaGetTrigOutNum(uint8_t security) {
  //Temporary unions for register read-write
  volatile DMAINFO_DMA_BUILDCFG1_Type info_bcfg;
  //Read registers
  if(security==0){
    info_bcfg.w = DMAINFO_S->DMA_BUILDCFG1;
  }
  else {
    info_bcfg.w = DMAINFO_NS->DMA_BUILDCFG1;
  }
  //Return number of trigger inputs
  return info_bcfg.b.NUM_TRIGGER_OUT;
}

uint32_t AdaSecurityViolationTestRead(void)
{
  return DMASECCTRL_NS->SEC_CHINTRSTATUS0;
}

 #endif /* __DMA_COMMAND_LIB_C */

