#ifndef __DMA_PL230_MCU_H
#define __DMA_PL230_MCU_H

#ifdef __cplusplus
extern "C" {
#endif
#include  "CMSDK_CM0.h"

#define DMA_PL230_BASE        (CMSDK_APB_BASE + 0xF000UL)

#define MAX_NUM_OF_DMA_CHANNELS   4

/*------------- PL230 uDMA (PL230) --------------------------------------*/
/** @addtogroup DMA_PL230 CMSDK uDMA controller
  @{
*/
typedef struct
{
  __I    uint32_t  DMA_STATUS;           /*!< Offset: 0x000 DMA status Register (R/W) */
  __O    uint32_t  DMA_CFG;              /*!< Offset: 0x004 DMA configuration Register ( /W) */
  __IO   uint32_t  CTRL_BASE_PTR;        /*!< Offset: 0x008 Channel Control Data Base Pointer Register  (R/W) */
  __I    uint32_t  ALT_CTRL_BASE_PTR;    /*!< Offset: 0x00C Channel Alternate Control Data Base Pointer Register  (R/ ) */
  __I    uint32_t  DMA_WAITONREQ_STATUS; /*!< Offset: 0x010 Channel Wait On Request Status Register  (R/ ) */
  __O    uint32_t  CHNL_SW_REQUEST;      /*!< Offset: 0x014 Channel Software Request Register  ( /W) */
  __IO   uint32_t  CHNL_USEBURST_SET;    /*!< Offset: 0x018 Channel UseBurst Set Register  (R/W) */
  __O    uint32_t  CHNL_USEBURST_CLR;    /*!< Offset: 0x01C Channel UseBurst Clear Register  ( /W) */
  __IO   uint32_t  CHNL_REQ_MASK_SET;    /*!< Offset: 0x020 Channel Request Mask Set Register  (R/W) */
  __O    uint32_t  CHNL_REQ_MASK_CLR;    /*!< Offset: 0x024 Channel Request Mask Clear Register  ( /W) */
  __IO   uint32_t  CHNL_ENABLE_SET;      /*!< Offset: 0x028 Channel Enable Set Register  (R/W) */
  __O    uint32_t  CHNL_ENABLE_CLR;      /*!< Offset: 0x02C Channel Enable Clear Register  ( /W) */
  __IO   uint32_t  CHNL_PRI_ALT_SET;     /*!< Offset: 0x030 Channel Primary-Alterante Set Register  (R/W) */
  __O    uint32_t  CHNL_PRI_ALT_CLR;     /*!< Offset: 0x034 Channel Primary-Alterante Clear Register  ( /W) */
  __IO   uint32_t  CHNL_PRIORITY_SET;    /*!< Offset: 0x038 Channel Priority Set Register  (R/W) */
  __O    uint32_t  CHNL_PRIORITY_CLR;    /*!< Offset: 0x03C Channel Priority Clear Register  ( /W) */
         uint32_t  RESERVED0[3];
  __IO   uint32_t  ERR_CLR;              /*!< Offset: 0x04C Bus Error Clear Register  (R/W) */

} DMA_PL230_TypeDef;

#define PL230_DMA_CHNL_BITS 0

#define DMA_PL230_DMA_STATUS_MSTREN_Pos          0                                                          /*!< DMA_PL230 DMA STATUS: MSTREN Position */
#define DMA_PL230_DMA_STATUS_MSTREN_Msk          (0x00000001ul << DMA_PL230_DMA_STATUS_MSTREN_Pos)        /*!< DMA_PL230 DMA STATUS: MSTREN Mask */

#define DMA_PL230_DMA_STATUS_STATE_Pos           0                                                          /*!< DMA_PL230 DMA STATUS: STATE Position */
#define DMA_PL230_DMA_STATUS_STATE_Msk           (0x0000000Ful << DMA_PL230_DMA_STATUS_STATE_Pos)         /*!< DMA_PL230 DMA STATUS: STATE Mask */

#define DMA_PL230_DMA_STATUS_CHNLS_MINUS1_Pos    0                                                          /*!< DMA_PL230 DMA STATUS: CHNLS_MINUS1 Position */
#define DMA_PL230_DMA_STATUS_CHNLS_MINUS1_Msk    (0x0000001Ful << DMA_PL230_DMA_STATUS_CHNLS_MINUS1_Pos)  /*!< DMA_PL230 DMA STATUS: CHNLS_MINUS1 Mask */

#define DMA_PL230_DMA_STATUS_TEST_STATUS_Pos     0                                                          /*!< DMA_PL230 DMA STATUS: TEST_STATUS Position */
#define DMA_PL230_DMA_STATUS_TEST_STATUS_Msk     (0x00000001ul << DMA_PL230_DMA_STATUS_TEST_STATUS_Pos)   /*!< DMA_PL230 DMA STATUS: TEST_STATUS Mask */

#define DMA_PL230_DMA_CFG_MSTREN_Pos             0                                                          /*!< DMA_PL230 DMA CFG: MSTREN Position */
#define DMA_PL230_DMA_CFG_MSTREN_Msk             (0x00000001ul << DMA_PL230_DMA_CFG_MSTREN_Pos)           /*!< DMA_PL230 DMA CFG: MSTREN Mask */

#define DMA_PL230_DMA_CFG_CPCCACHE_Pos           2                                                          /*!< DMA_PL230 DMA CFG: CPCCACHE Position */
#define DMA_PL230_DMA_CFG_CPCCACHE_Msk           (0x00000001ul << DMA_PL230_DMA_CFG_CPCCACHE_Pos)         /*!< DMA_PL230 DMA CFG: CPCCACHE Mask */

#define DMA_PL230_DMA_CFG_CPCBUF_Pos             1                                                          /*!< DMA_PL230 DMA CFG: CPCBUF Position */
#define DMA_PL230_DMA_CFG_CPCBUF_Msk             (0x00000001ul << DMA_PL230_DMA_CFG_CPCBUF_Pos)           /*!< DMA_PL230 DMA CFG: CPCBUF Mask */

#define DMA_PL230_DMA_CFG_CPCPRIV_Pos            0                                                          /*!< DMA_PL230 DMA CFG: CPCPRIV Position */
#define DMA_PL230_DMA_CFG_CPCPRIV_Msk            (0x00000001ul << DMA_PL230_DMA_CFG_CPCPRIV_Pos)          /*!< DMA_PL230 DMA CFG: CPCPRIV Mask */

#define DMA_PL230_CTRL_BASE_PTR_Pos              PL230_DMA_CHNL_BITS + 5                                    /*!< DMA_PL230 STATUS: BASE_PTR Position */
#define DMA_PL230_CTRL_BASE_PTR_Msk              (0x0FFFFFFFul << DMA_PL230_CTRL_BASE_PTR_Pos)            /*!< DMA_PL230 STATUS: BASE_PTR Mask */

#define DMA_PL230_ALT_CTRL_BASE_PTR_Pos          0                                                          /*!< DMA_PL230 STATUS: MSTREN Position */
#define DMA_PL230_ALT_CTRL_BASE_PTR_Msk          (0xFFFFFFFFul << DMA_PL230_ALT_CTRL_BASE_PTR_Pos)        /*!< DMA_PL230 STATUS: MSTREN Mask */

#define DMA_PL230_DMA_WAITONREQ_STATUS_Pos       0                                                          /*!< DMA_PL230 DMA_WAITONREQ_STATUS: DMA_WAITONREQ_STATUS Position */
#define DMA_PL230_DMA_WAITONREQ_STATUS_Msk       (0xFFFFFFFFul << DMA_PL230_DMA_WAITONREQ_STATUS_Pos)     /*!< DMA_PL230 DMA_WAITONREQ_STATUS: DMA_WAITONREQ_STATUS Mask */

#define DMA_PL230_CHNL_SW_REQUEST_Pos            0                                                          /*!< DMA_PL230 CHNL_SW_REQUEST: CHNL_SW_REQUEST Position */
#define DMA_PL230_CHNL_SW_REQUEST_Msk            (0xFFFFFFFFul << DMA_PL230_CHNL_SW_REQUEST_Pos)          /*!< DMA_PL230 CHNL_SW_REQUEST: CHNL_SW_REQUEST Mask */

#define DMA_PL230_CHNL_USEBURST_SET_Pos          0                                                          /*!< DMA_PL230 CHNL_USEBURST: SET Position */
#define DMA_PL230_CHNL_USEBURST_SET_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_USEBURST_SET_Pos)        /*!< DMA_PL230 CHNL_USEBURST: SET Mask */

#define DMA_PL230_CHNL_USEBURST_CLR_Pos          0                                                          /*!< DMA_PL230 CHNL_USEBURST: CLR Position */
#define DMA_PL230_CHNL_USEBURST_CLR_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_USEBURST_CLR_Pos)        /*!< DMA_PL230 CHNL_USEBURST: CLR Mask */

#define DMA_PL230_CHNL_REQ_MASK_SET_Pos          0                                                          /*!< DMA_PL230 CHNL_REQ_MASK: SET Position */
#define DMA_PL230_CHNL_REQ_MASK_SET_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_REQ_MASK_SET_Pos)        /*!< DMA_PL230 CHNL_REQ_MASK: SET Mask */

#define DMA_PL230_CHNL_REQ_MASK_CLR_Pos          0                                                          /*!< DMA_PL230 CHNL_REQ_MASK: CLR Position */
#define DMA_PL230_CHNL_REQ_MASK_CLR_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_REQ_MASK_CLR_Pos)        /*!< DMA_PL230 CHNL_REQ_MASK: CLR Mask */

#define DMA_PL230_CHNL_ENABLE_SET_Pos            0                                                          /*!< DMA_PL230 CHNL_ENABLE: SET Position */
#define DMA_PL230_CHNL_ENABLE_SET_Msk            (0xFFFFFFFFul << DMA_PL230_CHNL_ENABLE_SET_Pos)          /*!< DMA_PL230 CHNL_ENABLE: SET Mask */

#define DMA_PL230_CHNL_ENABLE_CLR_Pos            0                                                          /*!< DMA_PL230 CHNL_ENABLE: CLR Position */
#define DMA_PL230_CHNL_ENABLE_CLR_Msk            (0xFFFFFFFFul << DMA_PL230_CHNL_ENABLE_CLR_Pos)          /*!< DMA_PL230 CHNL_ENABLE: CLR Mask */

#define DMA_PL230_CHNL_PRI_ALT_SET_Pos           0                                                          /*!< DMA_PL230 CHNL_PRI_ALT: SET Position */
#define DMA_PL230_CHNL_PRI_ALT_SET_Msk           (0xFFFFFFFFul << DMA_PL230_CHNL_PRI_ALT_SET_Pos)         /*!< DMA_PL230 CHNL_PRI_ALT: SET Mask */

#define DMA_PL230_CHNL_PRI_ALT_CLR_Pos           0                                                          /*!< DMA_PL230 CHNL_PRI_ALT: CLR Position */
#define DMA_PL230_CHNL_PRI_ALT_CLR_Msk           (0xFFFFFFFFul << DMA_PL230_CHNL_PRI_ALT_CLR_Pos)         /*!< DMA_PL230 CHNL_PRI_ALT: CLR Mask */

#define DMA_PL230_CHNL_PRIORITY_SET_Pos          0                                                          /*!< DMA_PL230 CHNL_PRIORITY: SET Position */
#define DMA_PL230_CHNL_PRIORITY_SET_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_PRIORITY_SET_Pos)        /*!< DMA_PL230 CHNL_PRIORITY: SET Mask */

#define DMA_PL230_CHNL_PRIORITY_CLR_Pos          0                                                          /*!< DMA_PL230 CHNL_PRIORITY: CLR Position */
#define DMA_PL230_CHNL_PRIORITY_CLR_Msk          (0xFFFFFFFFul << DMA_PL230_CHNL_PRIORITY_CLR_Pos)        /*!< DMA_PL230 CHNL_PRIORITY: CLR Mask */

#define DMA_PL230_ERR_CLR_Pos                    0                                                          /*!< DMA_PL230 ERR: CLR Position */
#define DMA_PL230_ERR_CLR_Msk                    (0x00000001ul << DMA_PL230_ERR_CLR_Pos)                  /*!< DMA_PL230 ERR: CLR Mask */


#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))

                              /* Maximum to 32 DMA channel */
                              /* SRAM in example system is 64K bytes */
#define RAM_ADDRESS_MAX       0x80001fff

typedef struct /* 4 words */
{
  volatile unsigned char* SrcEndPointer;
  volatile unsigned char* DstEndPointer;
  volatile unsigned long Control;
  volatile unsigned long unused;
} dma_pl230_channel_data;


typedef struct /* 8 words per channel */
{ /* was one channel in the example uDMA setup */
  volatile dma_pl230_channel_data Primary[MAX_NUM_OF_DMA_CHANNELS];
  volatile dma_pl230_channel_data Alternate[MAX_NUM_OF_DMA_CHANNELS];
} dma_pl230_data_structure;


extern dma_pl230_data_structure *dma_pl230_table;

#define DMA_PL230_DMAC   ((DMA_PL230_TypeDef *)  DMA_PL230_BASE)

#define DMA_PL230_PTR_END(__ptr, __siz, __num) \
	((unsigned char *) __ptr + ((1<<__siz)*(__num-1)))

#define DMA_PL230_CTRL(__cyc, __siz, __num, __rpwr) \
	(((unsigned long) __siz << 30)|(__siz << 28)|(__siz << 26)|(__siz << 24)| \
         (1     << 21)|(1     << 18)|(__rpwr << 14)|(((__num-1)&0x3ff)<<4)| \
         (1     <<  3)|(__cyc <<  0) )

#define DMA_PL230_CTRL_SRCFIX(__cyc, __siz, __num, __rpwr) \
	(((unsigned long) __siz << 30)|(__siz << 28)|(0x0c000000UL)|(__siz << 24)| \
         (1     << 21)|(1     << 18)|(__rpwr << 14)|(((__num-1)&0x3ff)<<4)| \
         (1     <<  3)|(__cyc <<  0) )

#define DMA_PL230_CTRL_DSTFIX(__cyc, __siz, __num, __rpwr) \
	((0xc0000000UL)|(__siz << 28)|(__siz << 26)|(__siz << 24)| \
         (1     << 21)|(1     << 18)|(__rpwr << 14)|(((__num-1)&0x3ff)<<4)| \
         (1     <<  3)|(__cyc <<  0) )

#define DMA_PL230_MAX_XFERS (0x400)

#define PL230_CTRL_CYCLE_STOP    0
#define PL230_CTRL_CYCLE_BASIC   1
#define PL230_CTRL_CYCLE_AUTO    2
#define PL230_CTRL_CYCLE_PPONG   3
#define PL230_CTRL_CYCLE_MEM_CHAIN_PRI 4
#define PL230_CTRL_CYCLE_MEM_CHAIN_ALT 5
#define PL230_CTRL_CYCLE_DEV_CHAIN_PRI 6
#define PL230_CTRL_CYCLE_DEV_CHAIN_ALT 7

#define PL230_CTRL_RPWR_1  0
#define PL230_CTRL_RPWR_2  1
#define PL230_CTRL_RPWR_4  2
#define PL230_CTRL_RPWR_8  3
#define PL230_CTRL_RPWR_16 4

#define PL230_XFER_B    0
#define PL230_XFER_H    1
#define PL230_XFER_W    2

/* --------------------------------------------------------------- */
/*  Initialize DMA data structure                                  */
/* --------------------------------------------------------------- */
void dma_pl230_data_struct_init(void);

/* --------------------------------------------------------------- */
/*  Initialize DMA PL230                                           */
/* --------------------------------------------------------------- */
void dma_pl230_init_dbg(unsigned int chan_mask);
void dma_pl230_init(unsigned int chan_mask);

/* --------------------------------------------------------------- */
/*  Check DMA PL230 DMA channel(s) active (return 0 when finishes) */
/* --------------------------------------------------------------- */
unsigned int dma_pl230_channel_active(unsigned int chan_mask);

#ifdef __cplusplus
}
#endif

#endif /* __DMA_PL230_MCU_H */

