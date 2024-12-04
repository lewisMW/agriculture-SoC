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

#ifndef __DMA_COMMAND_LIB_H
#define __DMA_COMMAND_LIB_H

#include "dma_350_regdef.h"
#include "dma_350_reg_typedef.h"

#ifndef ADA_MAX_CH_NUM
#define ADA_MAX_CH_NUM 8
#endif

// DMA command related types

  typedef struct {
    uint32_t SRCMEMATTRLO:4;                /*!< bit:  0.. 3 SRCMEMATTRLO[ 3:0] */
    uint32_t SRCMEMATTRHI:4;                /*!< bit:  4.. 7 SRCMEMATTRHI[ 3:0] */
    uint32_t SRCSHAREATTR:2;                /*!< bit:  8.. 9 SRCSHAREATTR[ 1:0] */
    uint32_t SRCNONSECATTR:1;               /*!< bit:     10 SRCNONSECATTR */
    uint32_t SRCPRIVATTR:1;                 /*!< bit:     11 SRCPRIVATTR */
  } AdaChannelSrcAttrType;

    typedef struct {
    uint32_t DESMEMATTRLO:4;                /*!< bit:  0.. 3 DESMEMATTRLO[ 3:0] */
    uint32_t DESMEMATTRHI:4;                /*!< bit:  4.. 7 DESMEMATTRHI[ 3:0] */
    uint32_t DESSHAREATTR:2;                /*!< bit:  8.. 9 DESSHAREATTR[ 1:0] */
    uint32_t DESNONSECATTR:1;               /*!< bit:     10 DESNONSECATTR */
    uint32_t DESPRIVATTR:1;                 /*!< bit:     11 DESPRIVATTR */
  } AdaChannelDesAttrType;

    typedef struct {
    uint32_t CHPRIO:4;                      /*!< bit:  4.. 7 CHPRIO[ 3:0] */
    uint32_t CLEARCMD:1;                    /*!< bit:      1 CLEARCMD */
    uint32_t REGRELOADTYPE:3;               /*!< bit: 18..20 REGRELOADTYPE[ 2:0] */
    uint32_t DONETYPE:3;                    /*!< bit: 21..23 DONETYPE[ 2:0] */
    uint32_t DONEPAUSEEN:1;                 /*!< bit:     24 DONEPAUSEEN */
    uint32_t SRCMAXBURSTLEN:4;              /*!< bit: 16..19 SRCMAXBURSTLEN[ 3:0] */
    uint32_t DESMAXBURSTLEN:4;              /*!< bit: 16..19 DESMAXBURSTLEN[ 3:0] */
  } AdaChannelSettingsType;

  typedef struct {
    uint64_t SRCADDR:64;                    /*!< bit:  0..31 SRCADDRHI[31:0] + SRCADDR[31:0] */
    uint64_t DESADDR:64;                    /*!< bit:  0..31 DESADDRHI[31:0] + DESADDR[31:0] */
    uint32_t SRCXSIZE:32;                   /*!< bit:  0..15 SRCXSIZEHI[15:0] + SRCXSIZE[15:0] */
    uint32_t DESXSIZE:32;                   /*!< bit: 16..31 DESXSIZEHI[15:0] + DESXSIZE[15:0] */
    uint32_t TRANSIZE:3;                    /*!< bit:  0.. 2 TRANSIZE[ 2:0] */
  } AdaBaseCommandType;


  typedef struct {
    uint32_t SRCXADDRINC:16;                /*!< bit:  1..15 SRCXADDRINC[14:0] + 0 SRCXADDRINCLSB */
    uint32_t DESXADDRINC:16;                /*!< bit: 17..31 DESXADDRINC[14:0] + 16 DESXADDRINCLSB */
  } Ada1DIncrCommandType;

  typedef struct {
    uint32_t SRCYSIZE:16;                   /*!< bit:  0..15 SRCYSIZE[15:0] */
    uint32_t DESYSIZE:16;                   /*!< bit: 16..31 DESYSIZE[15:0] */
    uint32_t SRCYADDRSTRIDE:16;             /*!< bit:  0..15 SRCYADDRSTRIDE[15:0] */
    uint32_t DESYADDRSTRIDE:16;             /*!< bit: 16..31 DESYADDRSTRIDE[15:0] */
  } Ada2DCommandType;

  typedef struct {
    uint32_t FILLVAL:32;                    /*!< bit:  0..31 FILLVAL[31:0] */
    uint32_t XTYPE:3;                       /*!< bit:  9..11 XTYPE[ 2:0] */
    uint32_t YTYPE:3;                       /*!< bit: 12..14 YTYPE[ 2:0] */
  } AdaWrapCommandType;

  typedef struct {
    uint32_t SRCTMPLTSIZE:5;                /*!< bit:  8..12 SRCTMPLTSIZE[ 4:0] */
    uint32_t DESTMPLTSIZE:5;                /*!< bit: 16..20 DESTMPLTSIZE[ 4:0] */
    uint32_t SRCTMPLT:32;                   /*!< bit:  0..31 SRCTMPLT[31:0] */
    uint32_t DESTMPLT:32;                   /*!< bit:  0..31 DESTMPLT[31:0] */
  } AdaTMPLTCommandType;

  typedef struct {
    uint32_t STAT_DONE:1;                   /*!< bit:     16 STAT_DONE */
    uint32_t STAT_ERR:1;                    /*!< bit:     17 STAT_ERR */
    uint32_t STAT_DISABLED:1;               /*!< bit:     18 STAT_DISABLED */
    uint32_t STAT_STOPPED:1;                /*!< bit:     19 STAT_STOPPED */
    uint32_t STAT_PAUSED:1;                 /*!< bit:     20 STAT_PAUSED */
    uint32_t STAT_RESUMEWAIT:1;             /*!< bit:     21 STAT_RESUMEWAIT */
  } AdaStatType;

  typedef struct {
    uint32_t STAT_SRCTRIGINWAIT:1;          /*!< bit:     24 STAT_SRCTRIGINWAIT */
    uint32_t STAT_DESTRIGINWAIT:1;          /*!< bit:     25 STAT_DESTRIGINWAIT */
    uint32_t STAT_TRIGOUTACKWAIT:1;         /*!< bit:     26 STAT_TRIGOUTACKWAIT */
  } AdaTrigStatType;


  typedef struct {
    uint32_t INTR_DONE:1;                   /*!< bit:      0 INTR_DONE */
    uint32_t INTR_ERR:1;                    /*!< bit:      1 INTR_ERR */
    uint32_t INTR_DISABLED:1;               /*!< bit:      2 INTR_DISABLED */
    uint32_t INTR_STOPPED:1;                /*!< bit:      3 INTR_STOPPED */
    uint32_t INTR_SRCTRIGINWAIT:1;          /*!< bit:      8 INTR_SRCTRIGINWAIT */
    uint32_t INTR_DESTRIGINWAIT:1;          /*!< bit:      9 INTR_DESTRIGINWAIT */
    uint32_t INTR_TRIGOUTACKWAIT:1;         /*!< bit:     10 INTR_TRIGOUTACKWAIT */
  } AdaIrqType;

  typedef struct {
    uint32_t INTREN_DONE:1;                 /*!< bit:      0 INTREN_DONE */
    uint32_t INTREN_ERR:1;                  /*!< bit:      1 INTREN_ERR */
    uint32_t INTREN_DISABLED:1;             /*!< bit:      2 INTREN_DISABLED */
    uint32_t INTREN_STOPPED:1;              /*!< bit:      3 INTREN_STOPPED */
  } AdaIrqEnType;

  typedef struct {
    uint32_t INTREN_SRCTRIGINWAIT:1;        /*!< bit:      8 INTREN_SRCTRIGINWAIT */
    uint32_t INTREN_DESTRIGINWAIT:1;        /*!< bit:      9 INTREN_DESTRIGINWAIT */
    uint32_t INTREN_TRIGOUTACKWAIT:1;       /*!< bit:     10 INTREN_TRIGOUTACKWAIT */
  } AdaTrigIrqEnType;

  typedef struct {
    uint32_t BUSERR:1;                      /*!< bit:      0 BUSERR */
    uint32_t CFGERR:1;                      /*!< bit:      1 CFGERR */
    uint32_t SRCTRIGINSELERR:1;             /*!< bit:      2 SRCTRIGINSELERR */
    uint32_t DESTRIGINSELERR:1;             /*!< bit:      3 DESTRIGINSELERR */
    uint32_t TRIGOUTSELERR:1;               /*!< bit:      4 TRIGOUTSELERR */
    uint32_t STREAMERR:1;                   /*!< bit:      7 STREAMERR */
    uint32_t ERRINFO:16;                    /*!< bit: 16..31 ERRINFO[15:0] */
  } AdaErrInfoType;

    typedef struct {
    uint32_t SWTRIGINREQ:1;                 /*!< bit:         16/20 SWTRIGINREQ */
    uint32_t SWTRIGINTYPE:2;                /*!< bit: 17..18/21..22 SWTRIGINTYPE[ 1:0] */
  } AdaSwTrigInType;

  typedef struct {
    uint32_t USETRIGIN:1;                   /*!< bit:  25/26 USE*TRIGIN */
    uint32_t TRIGINSEL:8;                   /*!< bit:  0.. 7 TRIGINSEL[ 7:0] */
    uint32_t TRIGINTYPE:2;                  /*!< bit:  8.. 9 TRIGINTYPE[ 1:0] */
    uint32_t TRIGINMODE:2;                  /*!< bit: 10..11 TRIGINMODE[ 1:0] */
    uint32_t TRIGINBLKSIZE:8;               /*!< bit: 16..23 TRIGINBLKSIZE[ 7:0] */
  } AdaTrigInType;

  typedef struct {
    uint32_t USETRIGOUT:1;                  /*!< bit:     27 USETRIGOUT */
    uint32_t TRIGOUTSEL:6;                  /*!< bit:  0.. 5 TRIGOUTSEL[ 5:0] */
    uint32_t TRIGOUTTYPE:2;                 /*!< bit:  8.. 9 TRIGOUTTYPE[ 1:0] */
  } AdaTrigOutType;

  typedef struct {
    uint32_t USEGPO:1;                      /*!< bit:     28 USEGPO */
    uint32_t GPOEN0:32;                     /*!< bit:  0..31 GPOEN0[31:0] */
    uint32_t GPOEN1:32;                     /*!< bit:  0..31 GPOEN1[31:0] */
    uint32_t GPOVAL0:32;                    /*!< bit:  0..31 GPOVAL0[31:0] */
    uint32_t GPOVAL1:32;                    /*!< bit:  0..31 GPOVAL1[31:0] */
  } AdaGpoType;

  typedef struct {
    uint32_t STREAMTYPE:2;                  /*!< bit:  9..10 STREAMTYPE[ 1:0] */
  } AdaStreamType;

  typedef struct {
    uint32_t LINKMEMATTRLO:4;               /*!< bit:  0.. 3 SRCMEMATTRLO[ 3:0] */
    uint32_t LINKMEMATTRHI:4;               /*!< bit:  4.. 7 SRCMEMATTRHI[ 3:0] */
    uint32_t LINKSHAREATTR:2;               /*!< bit:  8.. 9 LINKSHAREATTR[ 1:0] */
  } AdaChannelLinkAttrType;

  typedef struct {
    uint32_t LINKADDREN:1;                  /*!< bit:      0 LINKADDREN */
    uint64_t LINKADDR:62;                   /*!< bit: LINKADDRHI[31:0] + LINKADDR[29:0] */
  } AdaCmdLinkType;

  typedef struct {
    uint32_t CMDRESTARTCNT:16;              /*!< bit:  0..15 CMDRESTARTCNT[15:0] */
    uint32_t CMDRESTARTINFEN:1;             /*!< bit:     16 CMDRESTARTINFEN */
  } AdaAutoRestartType;

  // Non-secure and Secure frame related typedefs

  typedef struct {
    uint32_t INTR_ANYCHINTR:1;              /*!< bit:      0 INTR_ANYCHINTR */
    uint32_t INTR_ALLCHIDLE:1;              /*!< bit:      1 INTR_ALLCHIDLE */
    uint32_t INTR_ALLCHSTOPPED:1;           /*!< bit:      2 INTR_ALLCHSTOPPED */
    uint32_t INTR_ALLCHPAUSED:1;            /*!< bit:      3 INTR_ALLCHPAUSED */
  } AdaCombIrqType;

  typedef struct {
    uint32_t STAT_ALLCHIDLE:1;              /*!< bit:     16 STAT_ALLCHIDLE */
    uint32_t STAT_ALLCHSTOPPED:1;           /*!< bit:     17 STAT_ALLCHSTOPPED */
    uint32_t STAT_ALLCHPAUSED:1;            /*!< bit:     18 STAT_ALLCHPAUSED */
  } AdaCombIrqClrType;

  typedef struct {
    uint32_t INTREN_ANYCHINTR:1;            /*!< bit:      0 INTREN_ANYCHINTR */
    uint32_t INTREN_ALLCHIDLE:1;            /*!< bit:      1 INTREN_ALLCHIDLE */
    uint32_t INTREN_ALLCHSTOPPED:1;         /*!< bit:      2 INTREN_ALLCHSTOPPED */
    uint32_t INTREN_ALLCHPAUSED:1;          /*!< bit:      3 INTREN_ALLCHPAUSED */
  } AdaCombIrqEnType;

  typedef struct {
    uint32_t CHPTR:6;                       /*!< bit:  0.. 5 CHSEL[ 5:0] */
    uint32_t CHID:16;                       /*!< bit:  0..15 CHID[15:0] */
    uint32_t CHIDVLD:1;                     /*!< bit:     16 CHIDVLD */
    uint32_t CHPRIV:1;                      /*!< bit:     17 CHPRIV */
  } AdaCombChCfgType;


// Command Link Header Register type definition
  typedef union {
    struct {
      uint32_t REGCLEAR:1;                  /*< bit:       0 Not referencing any registers. Used for the REGCLEAR bit */
      uint32_t RESERVED0:1;                 /*< bit:       1 Reserved for future use */
      uint32_t INTREN:1;                    /*< bit:       2 Same as in register bank */
      uint32_t CTRL:1;                      /*< bit:       3 Same as in register bank */
      uint32_t SRCADDR:1;                   /*< bit:       4 Same as in register bank */
      uint32_t SRCADDRHI:1;                 /*< bit:       5 Only present when 40-bit address width is used */
      uint32_t DESADDR:1;                   /*< bit:       6 Same as in register bank */
      uint32_t DESADDRHI:1;                 /*< bit:       7 Only present when 40-bit address width is used */
      uint32_t XSIZE:1;                     /*< bit:       8 Same as in register bank */
      uint32_t XSIZEHI:1;                   /*< bit:       9 Same as in register bank */
      uint32_t SRCTRANSCFG:1;               /*< bit:      10 Same as in register bank */
      uint32_t DESTRANSCFG:1;               /*< bit:      11 Same as in register bank */
      uint32_t XADDRINC:1;                  /*< bit:      12 Same as in register bank */
      uint32_t YADDRSTRIDE:1;               /*< bit:      13 Same as in register bank */
      uint32_t FILLVAL:1;                   /*< bit:      14 Same as in register bank */
      uint32_t YSIZE:1;                     /*< bit:      15 Same as in register bank */
      uint32_t TMPLTCFG:1;                  /*< bit:      16 Same as in register bank */
      uint32_t SRCTMPLT:1;                  /*< bit:      17 Same as in register bank */
      uint32_t DESTMPLT:1;                  /*< bit:      18 Same as in register bank */
      uint32_t SRCTRIGINCFG:1;              /*< bit:      19 Same as in register bank */
      uint32_t DESTRIGINCFG:1;              /*< bit:      20 Same as in register bank */
      uint32_t TRIGOUTCFG:1;                /*< bit:      21 Same as in register bank */
      uint32_t GPOEN0:1;                    /*< bit:      22 Same as in register bank */
      uint32_t GPOEN1:1;                    /*< bit:      23 Only present when more than 32 GPO present */
      uint32_t GPOVAL0:1;                   /*< bit:      24 Same as in register bank, only [GPOWIDTH-1:0] are implemented. */
      uint32_t GPOVAL1:1;                   /*< bit:      25 Only present when more than 32 GPO present */
      uint32_t STREAMINTCFG:1;              /*< bit:      26 Same as in register bank */
      uint32_t LINKATTR:1;                  /*< bit:      27 Same as in register bank */
      uint32_t RESERVED1:2;                 /*< bit:      28..29 Not used */
      uint32_t LINKADDR:1;                  /*< bit:      30 Same as in register bank */
      uint32_t LINKADDRHI:1;                /*< bit:      31 Only present when 40-bit address width is used */
    } b;
    uint32_t w;
  } AdaCmdLinkHeaderType;

  typedef enum AdaTransizeType_t
  {
      BYTE       = 0,
      BITS_8     = 0,
      HALFWORD   = 1,
      BITS_16    = 1,
      WORD       = 2,
      BITS_32    = 2,
      DOUBLEWORD = 3,
      BITS_64    = 3,
      BITS_128   = 4,
      BITS_256   = 5,
      BITS_512   = 6,
      BITS_1024  = 7
  } AdaTransizeType_t;

  typedef enum AdaCommandOperationType_t
  {
      OPTYPE_DISABLE  = 0,
      OPTYPE_CONTINUE = 1,
      OPTYPE_WRAP     = 2,
      OPTYPE_FILL     = 3
  } AdaCommandOperationType_t;

  typedef enum AdaReloadType_t
  {
      RELOAD_DISABLED           = 0,
      RELOAD_SIZES              = 1,
      RELOAD_SRC_ADDR_AND_SIZES = 3,
      RELOAD_DST_ADDR_AND_SIZES = 5,
      RELOAD_ADDRS_AND_SIZES    = 7
  } AdaReloadType_t;

  typedef enum AdaDoneType_t
  {
      DONETYPE_DISABLED         = 0,
      DONETYPE_EOF_CMD          = 1,
      DONETYPE_EOF_AUTORESTART  = 3
  } AdaDoneType_t;

  typedef enum AdaTriggerType_t
  {
      TRIGTYPE_SW_ONLY     = 0,
      TRIGTYPE_HW_EXTERNAL = 2,
      TRIGTYPE_HW_INTERNAL = 3
  } AdaTriggerType_t;

  typedef enum AdaTriggerInMode_t
  {
      TRIGINMODE_CMD     = 0,
      TRIGINMODE_DMA_FLW = 2,
      TRIGINMODE_PER_FLW = 3
  } AdaTriggerInMode_t;

  typedef enum AdaTriggerOutType_t
  {
      TRIGOUTTYPE_SW    = 0,
      TRIGOUTTYPE_HW    = 2,
      TRIGOUTTYPE_INT   = 3
  } AdaTriggerOutType_t;

  typedef enum AdaSwTriggerType_t
  {
      SINGLE      = 0,
      LAST_SINGLE = 1,
      BLOCK       = 2,
      LAST_BLOCK  = 3
  } AdaSwTriggerType_t;


  typedef enum AdaStreamType_t
  {
      IN_AND_OUT = 0,
      OUT_ONLY   = 1,
      IN_ONLY    = 2
  } AdaStreamType_t;

  typedef enum AdaSecurityType_t
  {
      SECURE     = 0,
      NON_SECURE = 1
  } AdaSecurityType_t;

  typedef enum AdaSecurityViolationResp_t
  {
      RAZWI     = 0,
      ERR_RESP  = 1
  } AdaSecurityViolationResp_t;

// External variables
// Channel pointers
extern DMACH_TypeDef *sec_dma_channels[3];
extern DMACH_TypeDef *nsec_dma_channels[3];

//Functions
DMACH_TypeDef* GetChannelPtr(uint32_t ch_num, uint8_t security);
void AdaEnable(uint32_t ch_num, uint8_t security);
uint8_t AdaGetEnable( uint32_t ch_num, uint8_t security);
void AdaStop(uint32_t ch_num, uint8_t security);
void AdaDisable(uint32_t ch_num, uint8_t security);
void AdaClear(uint32_t ch_num, uint8_t security);
void AdaPause(uint32_t ch_num, uint8_t security);
void AdaResume(uint32_t ch_num, uint8_t security);

void Ada1DCommand(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security);
uint32_t GetAdaActualSrcXSize(uint32_t ch_num, uint8_t security);
uint32_t GetAdaActualDesXSize(uint32_t ch_num, uint8_t security);
void SetAdaLong1DRegs(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security);
void AdaLong1DCommand(AdaBaseCommandType command_params, uint32_t ch_num, uint8_t security);

void AdaSetSrcTranAttrs(AdaChannelSrcAttrType src_attr, uint32_t ch_num, uint8_t security);
void AdaSetDesTranAttrs(AdaChannelDesAttrType des_attr, uint32_t ch_num, uint8_t security);
void AdaChannelSettings(AdaChannelSettingsType ch_params, uint32_t ch_num, uint8_t security);

void AdaChannelInit(AdaChannelSettingsType ch_params, AdaChannelSrcAttrType src_attr, AdaChannelDesAttrType des_attr, uint32_t ch_num, uint8_t security);
void SetAda1DIncrRegs(Ada1DIncrCommandType incr_params, uint32_t ch_num, uint8_t security);
void Ada1DIncrCommand(AdaBaseCommandType command_params, Ada1DIncrCommandType incr_params, uint32_t ch_num, uint8_t security);

void SetAda2DRegs(Ada2DCommandType y_params, uint32_t ch_num, uint8_t security);
void Ada2DCommand(AdaBaseCommandType command_params, Ada2DCommandType y_params, uint32_t ch_num, uint8_t security);

void SetAdaWrapRegs(AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security);
void AdaWrapCommand(AdaBaseCommandType command_params, AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security);
void AdaWrap2DCommand(AdaBaseCommandType command_params, Ada2DCommandType y_params, AdaWrapCommandType wrap_params, uint32_t ch_num, uint8_t security);

void SetAdaTmpltRegs(AdaTMPLTCommandType tmplt_params, uint32_t ch_num, uint8_t security);
void AdaTmpltCommand(AdaBaseCommandType command_params, AdaTMPLTCommandType tmplt_params, uint32_t ch_num, uint8_t security);

AdaStatType AdaReadStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChDoneStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChErrorStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChDisabledStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChStoppedStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChPausedStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChResumeWaitStatus(uint32_t ch_num, uint8_t security);

void AdaClearChDone(uint32_t ch_num, uint8_t security);
void AdaClearChError(uint32_t ch_num, uint8_t security);
void AdaClearChDisabled(uint32_t ch_num, uint8_t security);
void AdaClearChStopped(uint32_t ch_num, uint8_t security);
void AdaClearAllChIrq(uint32_t ch_num, uint8_t security);

AdaTrigStatType AdaReadTrigStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChSrcTrigInWaitStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChDesTrigInWaitStatus(uint32_t ch_num, uint8_t security);
uint8_t AdaChTrigOutAckWaitStatus(uint32_t ch_num, uint8_t security);

AdaIrqType AdaReadIrqStatus(uint32_t ch_num, uint8_t security);

void AdaSetIntEn(AdaIrqEnType int_en_params, uint32_t ch_num, uint8_t security);
void AdaSetDoneIntEn(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaSetErrorIntEn(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaSetDisabledIntEn(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaSetStoppedIntEn(uint8_t en, uint32_t ch_num, uint8_t security);

void AdaSetTrigIntEn(AdaTrigIrqEnType trig_int_en_params, uint32_t ch_num, uint8_t security);
void AdaSetSrcTrigInWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaSetDestTrigInWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaSetTrigOutAckWaitIntEn(uint8_t en, uint32_t ch_num, uint8_t security);

AdaErrInfoType AdaReadErrorInfo(uint32_t ch_num, uint8_t security);

AdaSwTrigInType AdaSrcSwTigInState(uint32_t ch_num, uint8_t security);
AdaSwTrigInType AdaDesSwTigInState(uint32_t ch_num, uint8_t security);
uint8_t AdaSwTrigOutState(uint32_t ch_num, uint8_t security);
void AdaDesSwTrigInReq(AdaSwTriggerType_t trigin_type, uint32_t ch_num, uint8_t security);
void AdaSrcSwTrigInReq(AdaSwTriggerType_t trigin_type, uint32_t ch_num, uint8_t security);
void AdaSwTrigOutAck(uint32_t ch_num, uint8_t security);

void AdaSrcTrigInInit(AdaTrigInType src_trigin_params, uint32_t ch_num, uint8_t security);
void AdaSrcTrigInEnable(uint8_t en, uint32_t ch_num, uint8_t security);
void AdaDesTrigInInit(AdaTrigInType des_trigin_params, uint32_t ch_num, uint8_t security);
void AdaDesTrigInEnable(uint8_t en, uint32_t ch_num, uint8_t security);

void AdaTrigOutInit(AdaTrigOutType trigout_params, uint32_t ch_num, uint8_t security);
void AdaTrigOutEnable(uint8_t en, uint32_t ch_num, uint8_t security);

void AdaStreamInit(AdaStreamType stream_params, uint32_t ch_num, uint8_t security);
void AdaStreamEnable(uint8_t en, uint32_t ch_num, uint8_t security);

void AdaSetLinkTranAttrs(AdaChannelLinkAttrType link_attr, uint32_t ch_num, uint8_t security);
void AdaSetCmdLink(AdaCmdLinkType cmd_link_params, uint32_t ch_num, uint8_t security);

uint8_t AdaGetLinkTranMemAttrs(uint32_t ch_num, uint8_t security);
uint8_t AdaGetLinkTranShareAttrs(uint32_t ch_num, uint8_t security);
uint64_t AdaGetCmdLinkAddr(uint32_t ch_num, uint8_t security);

void AdaAutoRestart(AdaAutoRestartType restart_params, uint32_t ch_num, uint8_t security);
void AdaSetRestartCntr(uint16_t restartcnt, uint32_t ch_num, uint8_t security);
void AdaInfRestart(uint8_t inf_restart_en, uint32_t ch_num, uint8_t security);

void AdaSetGPO(uint64_t gpo_value, uint32_t width, uint32_t ch_num, uint8_t security);

//Secure / Non-Secure Frame related functions
uint32_t GetNonSecCollIrqStat(void);
uint32_t GetSecCollIrqStat(void);
AdaCombIrqType AdaReadNSecCombIrqStatus(void);
AdaCombIrqType AdaReadSecCombIrqStatus(void);
uint8_t AdaNSecCombinedIrqState(void);
uint8_t AdaSecCombinedIrqState(void);
uint8_t AdaNSecAllIdleIrqState(void);
uint8_t AdaSecAllIdleIrqState(void);
uint8_t AdaNSecAllStoppedIrqState(void);
uint8_t AdaSecAllStoppedIrqState(void);
uint8_t AdaNSecAllPausedIrqState(void);
uint8_t AdaSecAllPausedIrqState(void);

AdaCombIrqClrType AdaReadSecCombStatus(void);
AdaCombIrqClrType AdaReadNSecCombStatus(void);
void AdaClrSecCombIrq(AdaCombIrqClrType clr_state);
void AdaClrNSecCombIrq(AdaCombIrqClrType clr_state);
void AdaClrSecAllChIdleIrq(void);
void AdaClrNSecAllChIdleIrq(void);
void AdaClrSecAllChStoppedIrq(void);
void AdaClrNSecAllChStoppedIrq(void);
void AdaClrSecAllChPausedIrq(void);
void AdaClrNSecAllChPausedIrq(void);

void AdaSecCombIrqEn(AdaCombIrqEnType irq_en);
void AdaNSecCombIrqEn(AdaCombIrqEnType irq_en);
void AdaSecCombCtrlIrqEn(uint8_t irq_en);
void AdaNSecCombCtrlIrqEn(uint8_t irq_en);
void AdaSecAllChIdleIrqEn(uint8_t irq_en);
void AdaNSecAllChIdleIrqEn(uint8_t irq_en);
void AdaSecAllChStoppedIrqEn(uint8_t irq_en);
void AdaNSecAllChStoppedIrqEn(uint8_t irq_en);
void AdaSecAllChPausedIrqEn(uint8_t irq_en);
void AdaNSecAllChPausedIrqEn(uint8_t irq_en);
void AdaSecIrqCombine(uint8_t en);
void AdaNSecIrqCombine(uint8_t en);

void AdaSecAllChStopReq(void);
void AdaNSecAllChStopReq(void);

void AdaSecAllChPauseReq(void);
void AdaNSecAllChPauseReq(void);

void AdaSecDisMinPwr(uint8_t dis_min_pwr);
void AdaNSecDisMinPwr(uint8_t dis_min_pwr);

void AdaSecSetChParams(AdaCombChCfgType ch_params);
void AdaNSecSetChParams(AdaCombChCfgType ch_params);

//Set channel Security Configuration
void AdaSetChSecMappig(uint32_t mapping);
void AdaSetChSecurity(uint32_t ch_num, uint32_t security);

void AdaSetTrigInSecMappig(uint32_t mapping);
void AdaSetTrigInSecurity(uint32_t trig_num, uint8_t security);

void AdaSetTrigOutSecMappig(uint32_t mapping);
void AdaSetTrigOutSecurity(uint32_t trig_num, uint8_t security);

void AdaSecSetChPtr(uint8_t ch);
void AdaNSecSetChPtr(uint8_t ch);
void AdaSecSetChId(uint8_t ch, uint16_t chid);
void AdaNSecSetChId(uint8_t ch, uint16_t chid);
void AdaSecSetChPrivileged(uint8_t ch, uint8_t privileged);
void AdaNSecSetChPrivileged(uint8_t ch, uint8_t privileged);

void AdaSecViolationIrqEn(uint8_t en);
void AdaSecViolationResp(uint8_t resp);
void AdaSecConfigLock(void);
uint8_t AdaSecViolationIrqState(void);
void AdaClrSecViolationIrq(void);

uint8_t AdaNSecAllPausedState(void);
uint8_t AdaSecAllPausedState(void);

uint32_t AdaGetChNum(uint8_t security);
uint32_t AdaGetTrigInNum(uint8_t security);
uint32_t AdaGetTrigOutNum(uint8_t security);

uint32_t AdaSecurityViolationTestRead(void);

#endif /* __DMA_COMMAND_LIB_H */

