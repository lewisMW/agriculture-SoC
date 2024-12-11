#ifndef _AES128_H_
#define _AES128_H_

#include <stdint.h>

// define the API addresses here. 

#define AES128_BASE        (0x60000000)

// byte address I/O buffers
#define AES128_BUF_SIZE   (0x4000)

typedef struct {
     __I  uint32_t CORE_NAME[2];   /* 0x0000-0007 */
     __I  uint32_t CORE_VERSION;   /* 0x0008-000B */
          uint32_t RESRV0C;        /* 0x000C */
     __IO uint32_t CTRL;           /* 0x0010 */
     __O  uint32_t CTRL_SET;       /* 0x0014 */
     __O  uint32_t CTRLL_CLR;      /* 0x0018 */
     __I  uint32_t STATUS;         /* 0x001c */
     __IO uint32_t QUAL;           /* 0x0020 */
          uint32_t RESRV24[3];     /* 0x0024 - 2F*/
     __IO uint32_t DRQ_MSK;        /* 0x0030 */
     __O  uint32_t DRQ_MSK_SET;    /* 0x0034 */
     __O  uint32_t DRQ_MSK_CLR;    /* 0x0038 */
     __I  uint32_t DRQ_STATUS;     /* 0x003C */
     __IO uint32_t IRQ_MSK;        /* 0x0040 */
     __O  uint32_t IRQ_MSK_SET;    /* 0x0044 */
     __O  uint32_t IRQ_MSK_CLR;    /* 0x0048 */
     __I  uint32_t IRQ_STATUS;     /* 0x004C */
          uint8_t RESRV50[AES128_BUF_SIZE - 0x50];/* 0x0050-0x3FFC (4096-20 words) */
     __IO uint8_t KEY128[AES128_BUF_SIZE];   /* 0x4000-7FFF (0x3FFF is last alias) */
     __IO uint8_t TXTIP128[AES128_BUF_SIZE]; /* 0x8000-BFFF (0x3FFF is last alias) */
     __I  uint8_t TXTOP128[AES128_BUF_SIZE]; /* 0xC000-FFFF (0x3FFF is last alias) */
} AES128_TypeDef;

#define AES128             ((AES128_TypeDef *) AES128_BASE )

#define AES_BLOCK_SIZE 16

#define AES_KEY_LEN_128 16

#define HW32_REG(ADDRESS)  (*((volatile unsigned long  *)(ADDRESS)))

#define  AES128_CTRL_REG_WIDTH   ( 8)
#define  AES128_CTRL_BIT_MAX     ( (CTRL_REG_WIDTH-1)
#define  AES128_CTRL_KEY_REQ_BIT (1<<0)
#define  AES128_CTRL_IP_REQ_BIT  (1<<1)
#define  AES128_CTRL_OP_REQ_BIT  (1<<2)
#define  AES128_CTRL_ERR_REQ_BIT (1<<3)
#define  AES128_CTRL_BYPASS_BIT  (1<<6)
#define  AES128_CTRL_ENCODE_BIT  (1<<7)
#define  AES128_STAT_REG_WIDTH   ( 8)
#define  AES128_STAT_KEY_REQ_BIT (1<<0)
#define  AES128_STAT_IP_REQ_BIT  (1<<1)
#define  AES128_STAT_OP_REQ_BIT  (1<<2)
#define  AES128_STAT_ERR_REQ_BIT (1<<3)
#define  AES128_STAT_KEYOK_BIT   (1<<4)
#define  AES128_STAT_VALID_BIT   (1<<5)
#define  AES128_STAT_BYPASS_BIT  (1<<6)
#define  AES128_STAT_ENCODE_BIT  (1<<7)
#define  AES128_KEY_REQ_BIT (1<<0)
#define  AES128_IP_REQ_BIT  (1<<1)
#define  AES128_OP_REQ_BIT  (1<<2)
#define  AES128_ERR_REQ_BIT (1<<3)
#define  AES128_KEYOK_BIT   (1<<4)
#define  AES128_VALID_BIT   (1<<5)
#define  AES128_BYPASS_BIT  (1<<6)
#define  AES128_ENCODE_BIT  (1<<7)

#endif // _AES128_H_
