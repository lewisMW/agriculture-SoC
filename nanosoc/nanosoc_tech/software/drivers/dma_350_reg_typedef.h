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

/******************************************************************************/
/*         Abstract : Generated register type definition header file          */
/******************************************************************************/

#ifndef __ADA_DMA_REG_TYPEDEF_H
#define __ADA_DMA_REG_TYPEDEF_H

#include <stdint.h>
/******************************************************************************/
/*                Type definitions for ADA_DMA register blocks                */
/******************************************************************************/
/*******************  Register type definitions for DMACH  ********************/

typedef union {
  struct {
    uint32_t ENABLECMD:1;                   /*!< bit:      0 ENABLECMD */
    uint32_t CLEARCMD:1;                    /*!< bit:      1 CLEARCMD */
    uint32_t DISABLECMD:1;                  /*!< bit:      2 DISABLECMD */
    uint32_t STOPCMD:1;                     /*!< bit:      3 STOPCMD */
    uint32_t PAUSECMD:1;                    /*!< bit:      4 PAUSECMD */
    uint32_t RESUMECMD:1;                   /*!< bit:      5 RESUMECMD */
    uint32_t RESERVED0:10;                  /*!< bit:  6..15 RESERVED0[ 9:0] */
    uint32_t SRCSWTRIGINREQ:1;              /*!< bit:     16 SRCSWTRIGINREQ */
    uint32_t SRCSWTRIGINTYPE:2;             /*!< bit: 17..18 SRCSWTRIGINTYPE[ 1:0] */
    uint32_t RESERVED1:1;                   /*!< bit:     19 RESERVED1 */
    uint32_t DESSWTRIGINREQ:1;              /*!< bit:     20 DESSWTRIGINREQ */
    uint32_t DESSWTRIGINTYPE:2;             /*!< bit: 21..22 DESSWTRIGINTYPE[ 1:0] */
    uint32_t RESERVED2:1;                   /*!< bit:     23 RESERVED2 */
    uint32_t SWTRIGOUTACK:1;                /*!< bit:     24 SWTRIGOUTACK */
    uint32_t RESERVED3:7;                   /*!< bit: 25..31 RESERVED3[ 6:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_CMD_Type;

typedef union {
  struct {
    uint32_t INTR_DONE:1;                   /*!< bit:      0 INTR_DONE */
    uint32_t INTR_ERR:1;                    /*!< bit:      1 INTR_ERR */
    uint32_t INTR_DISABLED:1;               /*!< bit:      2 INTR_DISABLED */
    uint32_t INTR_STOPPED:1;                /*!< bit:      3 INTR_STOPPED */
    uint32_t RESERVED0:4;                   /*!< bit:  4.. 7 RESERVED0[ 3:0] */
    uint32_t INTR_SRCTRIGINWAIT:1;          /*!< bit:      8 INTR_SRCTRIGINWAIT */
    uint32_t INTR_DESTRIGINWAIT:1;          /*!< bit:      9 INTR_DESTRIGINWAIT */
    uint32_t INTR_TRIGOUTACKWAIT:1;         /*!< bit:     10 INTR_TRIGOUTACKWAIT */
    uint32_t RESERVED1:5;                   /*!< bit: 11..15 RESERVED1[ 4:0] */
    uint32_t STAT_DONE:1;                   /*!< bit:     16 STAT_DONE */
    uint32_t STAT_ERR:1;                    /*!< bit:     17 STAT_ERR */
    uint32_t STAT_DISABLED:1;               /*!< bit:     18 STAT_DISABLED */
    uint32_t STAT_STOPPED:1;                /*!< bit:     19 STAT_STOPPED */
    uint32_t STAT_PAUSED:1;                 /*!< bit:     20 STAT_PAUSED */
    uint32_t STAT_RESUMEWAIT:1;             /*!< bit:     21 STAT_RESUMEWAIT */
    uint32_t RESERVED2:2;                   /*!< bit: 22..23 RESERVED2[ 1:0] */
    uint32_t STAT_SRCTRIGINWAIT:1;          /*!< bit:     24 STAT_SRCTRIGINWAIT */
    uint32_t STAT_DESTRIGINWAIT:1;          /*!< bit:     25 STAT_DESTRIGINWAIT */
    uint32_t STAT_TRIGOUTACKWAIT:1;         /*!< bit:     26 STAT_TRIGOUTACKWAIT */
    uint32_t RESERVED3:5;                   /*!< bit: 27..31 RESERVED3[ 4:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_STATUS_Type;

typedef union {
  struct {
    uint32_t INTREN_DONE:1;                 /*!< bit:      0 INTREN_DONE */
    uint32_t INTREN_ERR:1;                  /*!< bit:      1 INTREN_ERR */
    uint32_t INTREN_DISABLED:1;             /*!< bit:      2 INTREN_DISABLED */
    uint32_t INTREN_STOPPED:1;              /*!< bit:      3 INTREN_STOPPED */
    uint32_t RESERVED0:4;                   /*!< bit:  4.. 7 RESERVED0[ 3:0] */
    uint32_t INTREN_SRCTRIGINWAIT:1;        /*!< bit:      8 INTREN_SRCTRIGINWAIT */
    uint32_t INTREN_DESTRIGINWAIT:1;        /*!< bit:      9 INTREN_DESTRIGINWAIT */
    uint32_t INTREN_TRIGOUTACKWAIT:1;       /*!< bit:     10 INTREN_TRIGOUTACKWAIT */
    uint32_t RESERVED1:21;                  /*!< bit: 11..31 RESERVED1[20:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_INTREN_Type;

typedef union {
  struct {
    uint32_t TRANSIZE:3;                    /*!< bit:  0.. 2 TRANSIZE[ 2:0] */
    uint32_t RESERVED0:1;                   /*!< bit:      3 RESERVED0 */
    uint32_t CHPRIO:4;                      /*!< bit:  4.. 7 CHPRIO[ 3:0] */
    uint32_t RESERVED1:1;                   /*!< bit:      8 RESERVED1 */
    uint32_t XTYPE:3;                       /*!< bit:  9..11 XTYPE[ 2:0] */
    uint32_t YTYPE:3;                       /*!< bit: 12..14 YTYPE[ 2:0] */
    uint32_t RESERVED2:3;                   /*!< bit: 15..17 RESERVED2[ 2:0] */
    uint32_t REGRELOADTYPE:3;               /*!< bit: 18..20 REGRELOADTYPE[ 2:0] */
    uint32_t DONETYPE:3;                    /*!< bit: 21..23 DONETYPE[ 2:0] */
    uint32_t DONEPAUSEEN:1;                 /*!< bit:     24 DONEPAUSEEN */
    uint32_t USESRCTRIGIN:1;                /*!< bit:     25 USESRCTRIGIN */
    uint32_t USEDESTRIGIN:1;                /*!< bit:     26 USEDESTRIGIN */
    uint32_t USETRIGOUT:1;                  /*!< bit:     27 USETRIGOUT */
    uint32_t USEGPO:1;                      /*!< bit:     28 USEGPO */
    uint32_t USESTREAM:1;                   /*!< bit:     29 USESTREAM */
    uint32_t RESERVED3:2;                   /*!< bit: 30..31 RESERVED3[ 1:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_CTRL_Type;

typedef union {
  struct {
    uint32_t SRCADDR:32;                    /*!< bit:  0..31 SRCADDR[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_SRCADDR_Type;

typedef union {
  struct {
    uint32_t SRCADDRHI:32;                  /*!< bit:  0..31 SRCADDRHI[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_SRCADDRHI_Type;

typedef union {
  struct {
    uint32_t DESADDR:32;                    /*!< bit:  0..31 DESADDR[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_DESADDR_Type;

typedef union {
  struct {
    uint32_t DESADDRHI:32;                  /*!< bit:  0..31 DESADDRHI[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_DESADDRHI_Type;

typedef union {
  struct {
    uint32_t SRCXSIZE:16;                   /*!< bit:  0..15 SRCXSIZE[15:0] */
    uint32_t DESXSIZE:16;                   /*!< bit: 16..31 DESXSIZE[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_XSIZE_Type;

typedef union {
  struct {
    uint32_t SRCXSIZEHI:16;                 /*!< bit:  0..15 SRCXSIZEHI[15:0] */
    uint32_t DESXSIZEHI:16;                 /*!< bit: 16..31 DESXSIZEHI[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_XSIZEHI_Type;

typedef union {
  struct {
    uint32_t SRCMEMATTRLO:4;                /*!< bit:  0.. 3 SRCMEMATTRLO[ 3:0] */
    uint32_t SRCMEMATTRHI:4;                /*!< bit:  4.. 7 SRCMEMATTRHI[ 3:0] */
    uint32_t SRCSHAREATTR:2;                /*!< bit:  8.. 9 SRCSHAREATTR[ 1:0] */
    uint32_t SRCNONSECATTR:1;               /*!< bit:     10 SRCNONSECATTR */
    uint32_t SRCPRIVATTR:1;                 /*!< bit:     11 SRCPRIVATTR */
    uint32_t RESERVED0:4;                   /*!< bit: 12..15 RESERVED0[ 3:0] */
    uint32_t SRCMAXBURSTLEN:4;              /*!< bit: 16..19 SRCMAXBURSTLEN[ 3:0] */
    uint32_t RESERVED1:12;                  /*!< bit: 20..31 RESERVED1[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_SRCTRANSCFG_Type;

typedef union {
  struct {
    uint32_t DESMEMATTRLO:4;                /*!< bit:  0.. 3 DESMEMATTRLO[ 3:0] */
    uint32_t DESMEMATTRHI:4;                /*!< bit:  4.. 7 DESMEMATTRHI[ 3:0] */
    uint32_t DESSHAREATTR:2;                /*!< bit:  8.. 9 DESSHAREATTR[ 1:0] */
    uint32_t DESNONSECATTR:1;               /*!< bit:     10 DESNONSECATTR */
    uint32_t DESPRIVATTR:1;                 /*!< bit:     11 DESPRIVATTR */
    uint32_t RESERVED0:4;                   /*!< bit: 12..15 RESERVED0[ 3:0] */
    uint32_t DESMAXBURSTLEN:4;              /*!< bit: 16..19 DESMAXBURSTLEN[ 3:0] */
    uint32_t RESERVED1:12;                  /*!< bit: 20..31 RESERVED1[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_DESTRANSCFG_Type;

typedef union {
  struct {
    uint32_t SRCXADDRINC:16;                /*!< bit:  0..15 SRCXADDRINC[15:0] */
    uint32_t DESXADDRINC:16;                /*!< bit: 16..31 DESXADDRINC[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_XADDRINC_Type;

typedef union {
  struct {
    uint32_t SRCYADDRSTRIDE:16;             /*!< bit:  0..15 SRCYADDRSTRIDE[15:0] */
    uint32_t DESYADDRSTRIDE:16;             /*!< bit: 16..31 DESYADDRSTRIDE[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_YADDRSTRIDE_Type;

typedef union {
  struct {
    uint32_t FILLVAL:32;                    /*!< bit:  0..31 FILLVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_FILLVAL_Type;

typedef union {
  struct {
    uint32_t SRCYSIZE:16;                   /*!< bit:  0..15 SRCYSIZE[15:0] */
    uint32_t DESYSIZE:16;                   /*!< bit: 16..31 DESYSIZE[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_YSIZE_Type;

typedef union {
  struct {
    uint32_t RESERVED0:8;                   /*!< bit:  0.. 7 RESERVED0[ 7:0] */
    uint32_t SRCTMPLTSIZE:5;                /*!< bit:  8..12 SRCTMPLTSIZE[ 4:0] */
    uint32_t RESERVED1:3;                   /*!< bit: 13..15 RESERVED1[ 2:0] */
    uint32_t DESTMPLTSIZE:5;                /*!< bit: 16..20 DESTMPLTSIZE[ 4:0] */
    uint32_t RESERVED2:11;                  /*!< bit: 21..31 RESERVED2[10:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_TMPLTCFG_Type;

typedef union {
  struct {
    uint32_t SRCTMPLTLSB:1;                 /*!< bit:      0 SRCTMPLTLSB */
    uint32_t SRCTMPLT:31;                   /*!< bit:  1..31 SRCTMPLT[30:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_SRCTMPLT_Type;

typedef union {
  struct {
    uint32_t DESTMPLTLSB:1;                 /*!< bit:      0 DESTMPLTLSB */
    uint32_t DESTMPLT:31;                   /*!< bit:  1..31 DESTMPLT[30:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_DESTMPLT_Type;

typedef union {
  struct {
    uint32_t SRCTRIGINSEL:8;                /*!< bit:  0.. 7 SRCTRIGINSEL[ 7:0] */
    uint32_t SRCTRIGINTYPE:2;               /*!< bit:  8.. 9 SRCTRIGINTYPE[ 1:0] */
    uint32_t SRCTRIGINMODE:2;               /*!< bit: 10..11 SRCTRIGINMODE[ 1:0] */
    uint32_t RESERVED0:4;                   /*!< bit: 12..15 RESERVED0[ 3:0] */
    uint32_t SRCTRIGINBLKSIZE:8;            /*!< bit: 16..23 SRCTRIGINBLKSIZE[ 7:0] */
    uint32_t RESERVED1:8;                   /*!< bit: 24..31 RESERVED1[ 7:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_SRCTRIGINCFG_Type;

typedef union {
  struct {
    uint32_t DESTRIGINSEL:8;                /*!< bit:  0.. 7 DESTRIGINSEL[ 7:0] */
    uint32_t DESTRIGINTYPE:2;               /*!< bit:  8.. 9 DESTRIGINTYPE[ 1:0] */
    uint32_t DESTRIGINMODE:2;               /*!< bit: 10..11 DESTRIGINMODE[ 1:0] */
    uint32_t RESERVED0:4;                   /*!< bit: 12..15 RESERVED0[ 3:0] */
    uint32_t DESTRIGINBLKSIZE:8;            /*!< bit: 16..23 DESTRIGINBLKSIZE[ 7:0] */
    uint32_t RESERVED1:8;                   /*!< bit: 24..31 RESERVED1[ 7:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_DESTRIGINCFG_Type;

typedef union {
  struct {
    uint32_t TRIGOUTSEL:6;                  /*!< bit:  0.. 5 TRIGOUTSEL[ 5:0] */
    uint32_t RESERVED0:2;                   /*!< bit:  6.. 7 RESERVED0[ 1:0] */
    uint32_t TRIGOUTTYPE:2;                 /*!< bit:  8.. 9 TRIGOUTTYPE[ 1:0] */
    uint32_t RESERVED1:22;                  /*!< bit: 10..31 RESERVED1[21:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_TRIGOUTCFG_Type;

typedef union {
  struct {
    uint32_t GPOEN0:32;                     /*!< bit:  0..31 GPOEN0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_GPOEN0_Type;

typedef union {
  struct {
    uint32_t GPOVAL0:32;                    /*!< bit:  0..31 GPOVAL0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_GPOVAL0_Type;

typedef union {
  struct {
    uint32_t RESERVED0:9;                   /*!< bit:  0.. 8 RESERVED0[ 8:0] */
    uint32_t STREAMTYPE:2;                  /*!< bit:  9..10 STREAMTYPE[ 1:0] */
    uint32_t RESERVED1:21;                  /*!< bit: 11..31 RESERVED1[20:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_STREAMINTCFG_Type;

typedef union {
  struct {
    uint32_t LINKMEMATTRLO:4;               /*!< bit:  0.. 3 LINKMEMATTRLO[ 3:0] */
    uint32_t LINKMEMATTRHI:4;               /*!< bit:  4.. 7 LINKMEMATTRHI[ 3:0] */
    uint32_t LINKSHAREATTR:2;               /*!< bit:  8.. 9 LINKSHAREATTR[ 1:0] */
    uint32_t RESERVED0:22;                  /*!< bit: 10..31 RESERVED0[21:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_LINKATTR_Type;

typedef union {
  struct {
    uint32_t CMDRESTARTCNT:16;              /*!< bit:  0..15 CMDRESTARTCNT[15:0] */
    uint32_t CMDRESTARTINFEN:1;             /*!< bit:     16 CMDRESTARTINFEN */
    uint32_t RESERVED0:15;                  /*!< bit: 17..31 RESERVED0[14:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_AUTOCFG_Type;

typedef union {
  struct {
    uint32_t LINKADDREN:1;                  /*!< bit:      0 LINKADDREN */
    uint32_t RESERVED0:1;                   /*!< bit:      1 RESERVED0 */
    uint32_t LINKADDR:30;                   /*!< bit:  2..31 LINKADDR[29:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_LINKADDR_Type;

typedef union {
  struct {
    uint32_t LINKADDRHI:32;                 /*!< bit:  0..31 LINKADDRHI[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_LINKADDRHI_Type;

typedef union {
  struct {
    uint32_t GPOREAD0:32;                   /*!< bit:  0..31 GPOREAD0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_GPOREAD0_Type;

typedef union {
  struct {
    uint32_t WRKREGPTR:4;                   /*!< bit:  0.. 3 WRKREGPTR[ 3:0] */
    uint32_t RESERVED0:28;                  /*!< bit:  4..31 RESERVED0[27:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_WRKREGPTR_Type;

typedef union {
  struct {
    uint32_t WRKREGVAL:32;                  /*!< bit:  0..31 WRKREGVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_WRKREGVAL_Type;

typedef union {
  struct {
    uint32_t BUSERR:1;                      /*!< bit:      0 BUSERR */
    uint32_t CFGERR:1;                      /*!< bit:      1 CFGERR */
    uint32_t SRCTRIGINSELERR:1;             /*!< bit:      2 SRCTRIGINSELERR */
    uint32_t DESTRIGINSELERR:1;             /*!< bit:      3 DESTRIGINSELERR */
    uint32_t TRIGOUTSELERR:1;               /*!< bit:      4 TRIGOUTSELERR */
    uint32_t RESERVED0:2;                   /*!< bit:  5.. 6 RESERVED0[ 1:0] */
    uint32_t STREAMERR:1;                   /*!< bit:      7 STREAMERR */
    uint32_t RESERVED1:8;                   /*!< bit:  8..15 RESERVED1[ 7:0] */
    uint32_t ERRINFO:16;                    /*!< bit: 16..31 ERRINFO[15:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_ERRINFO_Type;

typedef union {
  struct {
    uint32_t IMPLEMENTER:12;                /*!< bit:  0..11 IMPLEMENTER[11:0] */
    uint32_t REVISION:4;                    /*!< bit: 12..15 REVISION[ 3:0] */
    uint32_t VARIANT:4;                     /*!< bit: 16..19 VARIANT[ 3:0] */
    uint32_t PRODUCTID:12;                  /*!< bit: 20..31 PRODUCTID[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_IIDR_Type;

typedef union {
  struct {
    uint32_t ARCH_MINOR_REV:4;              /*!< bit:  0.. 3 ARCH_MINOR_REV[ 3:0] */
    uint32_t ARCH_MAJOR_REV:4;              /*!< bit:  4.. 7 ARCH_MAJOR_REV[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_AIDR_Type;

typedef union {
  struct {
    uint32_t ISSUECAP:3;                    /*!< bit:  0.. 2 ISSUECAP[ 2:0] */
    uint32_t RESERVED0:29;                  /*!< bit:  3..31 RESERVED0[28:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_ISSUECAP_Type;

typedef union {
  struct {
    uint32_t DATA_BUFF_SIZE:8;              /*!< bit:  0.. 7 DATA_BUFF_SIZE[ 7:0] */
    uint32_t CMD_BUFF_SIZE:8;               /*!< bit:  8..15 CMD_BUFF_SIZE[ 7:0] */
    uint32_t ADDR_WIDTH:6;                  /*!< bit: 16..21 ADDR_WIDTH[ 5:0] */
    uint32_t DATA_WIDTH:3;                  /*!< bit: 22..24 DATA_WIDTH[ 2:0] */
    uint32_t RESERVED0:1;                   /*!< bit:     25 RESERVED0 */
    uint32_t INC_WIDTH:4;                   /*!< bit: 26..29 INC_WIDTH[ 3:0] */
    uint32_t RESERVED1:2;                   /*!< bit: 30..31 RESERVED1[ 1:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_BUILDCFG0_Type;

typedef union {
  struct {
    uint32_t HAS_XSIZEHI:1;                 /*!< bit:      0 HAS_XSIZEHI */
    uint32_t HAS_WRAP:1;                    /*!< bit:      1 HAS_WRAP */
    uint32_t HAS_2D:1;                      /*!< bit:      2 HAS_2D */
    uint32_t HAS_TMPLT:1;                   /*!< bit:      3 HAS_TMPLT */
    uint32_t HAS_TRIG:1;                    /*!< bit:      4 HAS_TRIG */
    uint32_t HAS_TRIGIN:1;                  /*!< bit:      5 HAS_TRIGIN */
    uint32_t HAS_TRIGOUT:1;                 /*!< bit:      6 HAS_TRIGOUT */
    uint32_t HAS_TRIGSEL:1;                 /*!< bit:      7 HAS_TRIGSEL */
    uint32_t HAS_CMDLINK:1;                 /*!< bit:      8 HAS_CMDLINK */
    uint32_t HAS_AUTO:1;                    /*!< bit:      9 HAS_AUTO */
    uint32_t HAS_WRKREG:1;                  /*!< bit:     10 HAS_WRKREG */
    uint32_t HAS_STREAM:1;                  /*!< bit:     11 HAS_STREAM */
    uint32_t HAS_STREAMSEL:1;               /*!< bit:     12 HAS_STREAMSEL */
    uint32_t RESERVED0:5;                   /*!< bit: 13..17 RESERVED0[ 4:0] */
    uint32_t HAS_GPOSEL:1;                  /*!< bit:     18 HAS_GPOSEL */
    uint32_t GPO_WIDTH:7;                   /*!< bit: 19..25 GPO_WIDTH[ 6:0] */
    uint32_t RESERVED1:6;                   /*!< bit: 26..31 RESERVED1[ 5:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMACH_CH_BUILDCFG1_Type;


/****************  Register type definitions for DMANSECCTRL  *****************/

typedef union {
  struct {
    uint32_t CHINTRSTATUS0:32;              /*!< bit:  0..31 CHINTRSTATUS0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_CHINTRSTATUS0_Type;

typedef union {
  struct {
    uint32_t INTR_ANYCHINTR:1;              /*!< bit:      0 INTR_ANYCHINTR */
    uint32_t INTR_ALLCHIDLE:1;              /*!< bit:      1 INTR_ALLCHIDLE */
    uint32_t INTR_ALLCHSTOPPED:1;           /*!< bit:      2 INTR_ALLCHSTOPPED */
    uint32_t INTR_ALLCHPAUSED:1;            /*!< bit:      3 INTR_ALLCHPAUSED */
    uint32_t RESERVED0:13;                  /*!< bit:  4..16 RESERVED0[12:0] */
    uint32_t STAT_ALLCHIDLE:1;              /*!< bit:     17 STAT_ALLCHIDLE */
    uint32_t STAT_ALLCHSTOPPED:1;           /*!< bit:     18 STAT_ALLCHSTOPPED */
    uint32_t STAT_ALLCHPAUSED:1;            /*!< bit:     19 STAT_ALLCHPAUSED */
    uint32_t RESERVED1:12;                  /*!< bit: 20..31 RESERVED1[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_STATUS_Type;

typedef union {
  struct {
    uint32_t INTREN_ANYCHINTR:1;            /*!< bit:      0 INTREN_ANYCHINTR */
    uint32_t INTREN_ALLCHIDLE:1;            /*!< bit:      1 INTREN_ALLCHIDLE */
    uint32_t INTREN_ALLCHSTOPPED:1;         /*!< bit:      2 INTREN_ALLCHSTOPPED */
    uint32_t INTREN_ALLCHPAUSED:1;          /*!< bit:      3 INTREN_ALLCHPAUSED */
    uint32_t RESERVED0:4;                   /*!< bit:  4.. 7 RESERVED0[ 3:0] */
    uint32_t ALLCHSTOP:1;                   /*!< bit:      8 ALLCHSTOP */
    uint32_t ALLCHPAUSE:1;                  /*!< bit:      9 ALLCHPAUSE */
    uint32_t RESERVED1:17;                  /*!< bit: 10..26 RESERVED1[16:0] */
    uint32_t DBGHALTNSRO:1;                 /*!< bit:     27 DBGHALTNSRO */
    uint32_t DBGHALTEN:1;                   /*!< bit:     28 DBGHALTEN */
    uint32_t IDLERETEN:1;                   /*!< bit:     29 IDLERETEN */
    uint32_t DISMINPWR:2;                   /*!< bit: 30..31 DISMINPWR[ 1:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_CTRL_Type;

typedef union {
  struct {
    uint32_t CHPTR:6;                       /*!< bit:  0.. 5 CHPTR[ 5:0] */
    uint32_t RESERVED0:26;                  /*!< bit:  6..31 RESERVED0[25:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_CHPTR_Type;

typedef union {
  struct {
    uint32_t CHID:16;                       /*!< bit:  0..15 CHID[15:0] */
    uint32_t CHIDVLD:1;                     /*!< bit:     16 CHIDVLD */
    uint32_t CHPRIV:1;                      /*!< bit:     17 CHPRIV */
    uint32_t RESERVED0:14;                  /*!< bit: 18..31 RESERVED0[13:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_CHCFG_Type;

typedef union {
  struct {
    uint32_t NSECSTATUSPTR:4;               /*!< bit:  0.. 3 NSECSTATUSPTR[ 3:0] */
    uint32_t RESERVED0:28;                  /*!< bit:  4..31 RESERVED0[27:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_STATUSPTR_Type;

typedef union {
  struct {
    uint32_t NSECSTATUSVAL:32;              /*!< bit:  0..31 NSECSTATUSVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_STATUSVAL_Type;

typedef union {
  struct {
    uint32_t NSECSIGNALPTR:4;               /*!< bit:  0.. 3 NSECSIGNALPTR[ 3:0] */
    uint32_t RESERVED0:28;                  /*!< bit:  4..31 RESERVED0[27:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_SIGNALPTR_Type;

typedef union {
  struct {
    uint32_t NSECSIGNALVAL:32;              /*!< bit:  0..31 NSECSIGNALVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMANSECCTRL_NSEC_SIGNALVAL_Type;


/*****************  Register type definitions for DMASECCTRL  *****************/

typedef union {
  struct {
    uint32_t CHINTRSTATUS0:32;              /*!< bit:  0..31 CHINTRSTATUS0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_CHINTRSTATUS0_Type;

typedef union {
  struct {
    uint32_t INTR_ANYCHINTR:1;              /*!< bit:      0 INTR_ANYCHINTR */
    uint32_t INTR_ALLCHIDLE:1;              /*!< bit:      1 INTR_ALLCHIDLE */
    uint32_t INTR_ALLCHSTOPPED:1;           /*!< bit:      2 INTR_ALLCHSTOPPED */
    uint32_t INTR_ALLCHPAUSED:1;            /*!< bit:      3 INTR_ALLCHPAUSED */
    uint32_t RESERVED0:13;                  /*!< bit:  4..16 RESERVED0[12:0] */
    uint32_t STAT_ALLCHIDLE:1;              /*!< bit:     17 STAT_ALLCHIDLE */
    uint32_t STAT_ALLCHSTOPPED:1;           /*!< bit:     18 STAT_ALLCHSTOPPED */
    uint32_t STAT_ALLCHPAUSED:1;            /*!< bit:     19 STAT_ALLCHPAUSED */
    uint32_t RESERVED1:12;                  /*!< bit: 20..31 RESERVED1[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_STATUS_Type;

typedef union {
  struct {
    uint32_t INTREN_ANYCHINTR:1;            /*!< bit:      0 INTREN_ANYCHINTR */
    uint32_t INTREN_ALLCHIDLE:1;            /*!< bit:      1 INTREN_ALLCHIDLE */
    uint32_t INTREN_ALLCHSTOPPED:1;         /*!< bit:      2 INTREN_ALLCHSTOPPED */
    uint32_t INTREN_ALLCHPAUSED:1;          /*!< bit:      3 INTREN_ALLCHPAUSED */
    uint32_t RESERVED0:4;                   /*!< bit:  4.. 7 RESERVED0[ 3:0] */
    uint32_t ALLCHSTOP:1;                   /*!< bit:      8 ALLCHSTOP */
    uint32_t ALLCHPAUSE:1;                  /*!< bit:      9 ALLCHPAUSE */
    uint32_t RESERVED1:17;                  /*!< bit: 10..26 RESERVED1[16:0] */
    uint32_t DBGHALTNSRO:1;                 /*!< bit:     27 DBGHALTNSRO */
    uint32_t DBGHALTEN:1;                   /*!< bit:     28 DBGHALTEN */
    uint32_t IDLERETEN:1;                   /*!< bit:     29 IDLERETEN */
    uint32_t DISMINPWR:2;                   /*!< bit: 30..31 DISMINPWR[ 1:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_CTRL_Type;

typedef union {
  struct {
    uint32_t CHPTR:6;                       /*!< bit:  0.. 5 CHPTR[ 5:0] */
    uint32_t RESERVED0:26;                  /*!< bit:  6..31 RESERVED0[25:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_CHPTR_Type;

typedef union {
  struct {
    uint32_t CHID:16;                       /*!< bit:  0..15 CHID[15:0] */
    uint32_t CHIDVLD:1;                     /*!< bit:     16 CHIDVLD */
    uint32_t CHPRIV:1;                      /*!< bit:     17 CHPRIV */
    uint32_t RESERVED0:14;                  /*!< bit: 18..31 RESERVED0[13:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_CHCFG_Type;

typedef union {
  struct {
    uint32_t SECSTATUSPTR:4;                /*!< bit:  0.. 3 SECSTATUSPTR[ 3:0] */
    uint32_t RESERVED0:28;                  /*!< bit:  4..31 RESERVED0[27:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_STATUSPTR_Type;

typedef union {
  struct {
    uint32_t SECSTATUSVAL:32;               /*!< bit:  0..31 SECSTATUSVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_STATUSVAL_Type;

typedef union {
  struct {
    uint32_t SECSIGNALPTR:4;                /*!< bit:  0.. 3 SECSIGNALPTR[ 3:0] */
    uint32_t RESERVED0:28;                  /*!< bit:  4..31 RESERVED0[27:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_SIGNALPTR_Type;

typedef union {
  struct {
    uint32_t SECSIGNALVAL:32;               /*!< bit:  0..31 SECSIGNALVAL[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCTRL_SEC_SIGNALVAL_Type;


/*****************  Register type definitions for DMASECCFG  ******************/

typedef union {
  struct {
    uint32_t SCFGCHSEC0:32;                 /*!< bit:  0..31 SCFGCHSEC0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCFG_SCFG_CHSEC0_Type;

typedef union {
  struct {
    uint32_t SCFGTRIGINSEC0:32;             /*!< bit:  0..31 SCFGTRIGINSEC0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCFG_SCFG_TRIGINSEC0_Type;

typedef union {
  struct {
    uint32_t SCFGTRIGOUTSEC0:32;            /*!< bit:  0..31 SCFGTRIGOUTSEC0[31:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCFG_SCFG_TRIGOUTSEC0_Type;

typedef union {
  struct {
    uint32_t INTREN_SECACCVIO:1;            /*!< bit:      0 INTREN_SECACCVIO */
    uint32_t RSPTYPE_SECACCVIO:1;           /*!< bit:      1 RSPTYPE_SECACCVIO */
    uint32_t RESERVED0:29;                  /*!< bit:  2..30 RESERVED0[28:0] */
    uint32_t SEC_CFG_LCK:1;                 /*!< bit:     31 SEC_CFG_LCK */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCFG_SCFG_CTRL_Type;

typedef union {
  struct {
    uint32_t INTR_SECACCVIO:1;              /*!< bit:      0 INTR_SECACCVIO */
    uint32_t RESERVED0:15;                  /*!< bit:  1..15 RESERVED0[14:0] */
    uint32_t STAT_SECACCVIO:1;              /*!< bit:     16 STAT_SECACCVIO */
    uint32_t RESERVED1:15;                  /*!< bit: 17..31 RESERVED1[14:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMASECCFG_SCFG_INTRSTATUS_Type;


/******************  Register type definitions for DMAINFO  *******************/

typedef union {
  struct {
    uint32_t FRAMETYPE:3;                   /*!< bit:  0.. 2 FRAMETYPE[ 2:0] */
    uint32_t RESERVED0:1;                   /*!< bit:      3 RESERVED0 */
    uint32_t NUM_CHANNELS:6;                /*!< bit:  4.. 9 NUM_CHANNELS[ 5:0] */
    uint32_t ADDR_WIDTH:6;                  /*!< bit: 10..15 ADDR_WIDTH[ 5:0] */
    uint32_t DATA_WIDTH:3;                  /*!< bit: 16..18 DATA_WIDTH[ 2:0] */
    uint32_t RESERVED1:1;                   /*!< bit:     19 RESERVED1 */
    uint32_t CHID_WIDTH:5;                  /*!< bit: 20..24 CHID_WIDTH[ 4:0] */
    uint32_t RESERVED2:7;                   /*!< bit: 25..31 RESERVED2[ 6:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_DMA_BUILDCFG0_Type;

typedef union {
  struct {
    uint32_t NUM_TRIGGER_IN:9;              /*!< bit:  0.. 8 NUM_TRIGGER_IN[ 8:0] */
    uint32_t NUM_TRIGGER_OUT:7;             /*!< bit:  9..15 NUM_TRIGGER_OUT[ 6:0] */
    uint32_t HAS_TRIGSEL:1;                 /*!< bit:     16 HAS_TRIGSEL */
    uint32_t RESERVED0:7;                   /*!< bit: 17..23 RESERVED0[ 6:0] */
    uint32_t RESERVED1:1;                   /*!< bit:     24 RESERVED1 */
    uint32_t RESERVED2:7;                   /*!< bit: 25..31 RESERVED2[ 6:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_DMA_BUILDCFG1_Type;

typedef union {
  struct {
    uint32_t RESERVED0:7;                   /*!< bit:  0.. 6 RESERVED0[ 6:0] */
    uint32_t HAS_GPOSEL:1;                  /*!< bit:      7 HAS_GPOSEL */
    uint32_t HAS_TZ:1;                      /*!< bit:      8 HAS_TZ */
    uint32_t HAS_RET:1;                     /*!< bit:      9 HAS_RET */
    uint32_t RESERVED1:1;                   /*!< bit:     10 RESERVED1 */
    uint32_t RESERVED2:1;                   /*!< bit:     11 RESERVED2 */
    uint32_t RESERVED3:20;                  /*!< bit: 12..31 RESERVED3[19:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_DMA_BUILDCFG2_Type;

typedef union {
  struct {
    uint32_t IMPLEMENTER:12;                /*!< bit:  0..11 IMPLEMENTER[11:0] */
    uint32_t REVISION:4;                    /*!< bit: 12..15 REVISION[ 3:0] */
    uint32_t VARIANT:4;                     /*!< bit: 16..19 VARIANT[ 3:0] */
    uint32_t PRODUCTID:12;                  /*!< bit: 20..31 PRODUCTID[11:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_IIDR_Type;

typedef union {
  struct {
    uint32_t ARCH_MINOR_REV:4;              /*!< bit:  0.. 3 ARCH_MINOR_REV[ 3:0] */
    uint32_t ARCH_MAJOR_REV:4;              /*!< bit:  4.. 7 ARCH_MAJOR_REV[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_AIDR_Type;

typedef union {
  struct {
    uint32_t DES_2:4;                       /*!< bit:  0.. 3 DES_2[ 3:0] */
    uint32_t SIZE:4;                        /*!< bit:  4.. 7 SIZE[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_PIDR4_Type;

typedef union {
  struct {
    uint32_t PART_0:8;                      /*!< bit:  0.. 7 PART_0[ 7:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_PIDR0_Type;

typedef union {
  struct {
    uint32_t PART_1:4;                      /*!< bit:  0.. 3 PART_1[ 3:0] */
    uint32_t DES_0:4;                       /*!< bit:  4.. 7 DES_0[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_PIDR1_Type;

typedef union {
  struct {
    uint32_t DES_1:3;                       /*!< bit:  0.. 2 DES_1[ 2:0] */
    uint32_t JEDEC:1;                       /*!< bit:      3 JEDEC */
    uint32_t REVISION:4;                    /*!< bit:  4.. 7 REVISION[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_PIDR2_Type;

typedef union {
  struct {
    uint32_t CMOD:4;                        /*!< bit:  0.. 3 CMOD[ 3:0] */
    uint32_t REVAND:4;                      /*!< bit:  4.. 7 REVAND[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_PIDR3_Type;

typedef union {
  struct {
    uint32_t PRMBL_0:8;                     /*!< bit:  0.. 7 PRMBL_0[ 7:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_CIDR0_Type;

typedef union {
  struct {
    uint32_t PRMBL_1:4;                     /*!< bit:  0.. 3 PRMBL_1[ 3:0] */
    uint32_t CLASS:4;                       /*!< bit:  4.. 7 CLASS[ 3:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_CIDR1_Type;

typedef union {
  struct {
    uint32_t PRMBL_2:8;                     /*!< bit:  0.. 7 PRMBL_2[ 7:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_CIDR2_Type;

typedef union {
  struct {
    uint32_t PRMBL_3:8;                     /*!< bit:  0.. 7 PRMBL_3[ 7:0] */
    uint32_t RESERVED0:24;                  /*!< bit:  8..31 RESERVED0[23:0] */
  } b;                                      /*!< Structure used for bit access */
  uint32_t w;                               /*!< Type used for word access */
  } DMAINFO_CIDR3_Type;



#endif /* __ADA_DMA_REG_TYPEDEF_H */

