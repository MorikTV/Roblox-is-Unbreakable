--Roblox-is-Unbreakable script by morikTVytube#2115
-- Lua simple XOR encrypt by Ganlv
-- https://github.com/ganlvtech/lua-simple-encrypt
key="morik"local a=loadstring((function(b,c)function bxor(d,e)local f={{0,1},{1,0}}local g=1;local h=0;while d>0 or e>0 do h=h+f[d%2+1][e%2+1]*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return h end;local i=function(b)local j={}local k=1;local l=b[k]while l>=0 do j[k]=b[l+1]k=k+1;l=b[k]end;return j end;local m=function(b,c)if#c<=0 then return{}end;local k=1;local n=1;for k=1,#b do b[k]=bxor(b[k],string.byte(c,n))n=n+1;if n>#c then n=1 end end;return b end;local o=function(b)local j=""for k=1,#b do j=j..string.char(b[k])end;return j end;return o(m(i(b),c))end)({3259,3608,2535,4434,4030,4861,3817,4947,2710,4488,2950,4110,4356,4834,4002,4166,4098,3029,3504,3026,3362,3345,4141,4061,4408,3219,4946,4049,4447,3340,4892,4626,4056,3181,4028,3400,2767,3835,2858,4003,2647,2605,3094,4153,3239,3904,4983,2962,4366,3174,2481,3952,3010,4250,2593,4703,3197,4411,2825,4019,4966,3108,3636,4245,3849,2809,3404,2588,4507,2803,3471,3161,3076,4874,3288,3710,3251,5037,3903,4906,3474,3331,4115,4060,3983,4782,4837,3823,3822,4499,3447,4794,4950,3943,3369,3685,4237,4446,3554,3815,4419,4136,3619,3036,4313,4919,3273,3799,2465,3004,2466,3024,3145,2680,2897,4640,3886,2667,4925,2919,4509,4602,4327,2854,3252,4749,3360,4931,4770,3472,4620,3294,3885,4301,4963,2979,4621,4346,2707,3589,4912,3521,4967,3434,2476,2763,4769,4368,4743,3702,4839,3657,3393,4289,4624,3099,4088,2818,4528,2674,5021,5022,3865,2657,4636,3158,4276,4212,2937,4158,4240,4433,4698,3045,2843,3727,4090,4534,4209,2580,4783,3944,2766,3869,3962,4685,3156,3816,4210,4585,4074,3382,4355,4324,3825,4493,4338,3409,3644,3080,4416,4204,2624,4016,3568,3900,3599,5000,4964,4953,4203,3440,3863,4000,2983,2851,4177,5043,4042,2837,3463,4243,3508,4706,4260,2951,3211,2976,2651,3988,4865,4351,4846,3348,3415,2883,3313,3525,4876,3936,2697,3490,4737,3018,3347,4674,3193,2617,4922,4573,4915,2678,4396,4182,4010,2805,3678,4342,3768,3766,2499,4711,3902,2770,4360,3461,3011,2713,4821,2656,2681,2524,2961,2549,4870,4263,4576,3260,2621,2661,4707,2935,3792,4057,3891,3436,4033,4928,2606,2997,3758,4191,3801,2890,2755,2518,4418,2577,4274,3933,2616,2993,3723,4930,3497,4505,4567,2715,2635,2982,4120,2772,4962,3272,4425,3893,4353,2899,2723,4808,3911,3972,3726,3315,4296,2932,2615,2750,2717,2652,2619,3845,3986,4530,2670,4113,4526,3346,4271,4048,2541,4877,3517,4795,4518,2631,3738,3364,4376,2608,2920,3652,2731,4692,4261,4908,3940,4771,2575,4664,4102,4067,3265,4206,2905,4926,4435,2986,3453,4995,4634,4202,4815,4382,4527,4813,4302,4303,4559,3366,4293,3769,3455,3065,2555,4112,4957,4384,3195,2857,3789,4790,4941,4026,2860,3689,2702,3295,3189,3241,4148,3882,4456,4469,3074,3187,2591,3184,4642,4140,2840,3016,2795,4078,2508,3383,4551,2730,2727,3861,2691,2765,3015,3443,4046,4395,2804,5001,3714,4929,4241,4511,5041,4646,3819,4326,2682,4689,4648,4651,3058,3576,3600,2627,2514,3746,5017,3748,3037,4459,3191,3760,2778,2486,4253,4316,2630,4039,2483,4949,4561,2873,2797,3683,3807,3017,2612,4753,4864,4064,4618,4784,2570,4728,3407,3516,4027,3128,4842,4801,4134,4578,3043,3505,2501,4370,2594,3740,4417,4893,2461,4944,3601,2742,3177,3722,2802,3287,2752,4726,3334,4330,3356,3165,4336,4410,4483,3725,4393,2633,3802,2654,4127,3509,4891,4502,3539,4826,4373,3999,2574,3737,3654,3887,4230,4816,2558,4427,3139,3851,3091,4412,4337,4522,4150,2827,4609,4718,3514,3693,4399,2538,2556,4319,2969,4121,4083,4974,4069,4840,4465,4535,3950,3735,2762,3624,2886,3704,2719,3951,4764,3159,4285,3279,4215,2671,3253,4657,2638,3354,2477,3143,3243,4183,3414,2711,4745,3971,4577,2546,3213,4144,2695,3623,3687,2844,4690,3269,2960,4985,3297,4701,3464,4428,5024,4863,4068,3282,4443,4975,4780,3031,3223,3954,3854,4437,2645,2733,2653,4723,3571,2995,4317,2550,2815,2743,3708,4547,4463,2692,3707,3957,4558,3942,4754,3577,3428,4951,4608,4924,2507,3860,3155,4904,3152,2677,2855,4091,3680,2527,3325,3528,4704,4603,4523,4135,4453,3240,3405,3580,2830,3311,4470,4984,3796,4478,3118,4235,3515,3730,4314,3534,2779,4691,4858,3546,3648,3014,3162,3790,3530,4197,2568,4163,2734,4748,5010,4684,3019,2623,3396,3216,3834,2990,3994,2745,3225,2525,4580,3084,4541,4630,3050,4485,2759,4041,3709,4804,4389,3113,2699,3425,2882,3102,3357,3095,4156,4628,4254,4441,5011,4641,4818,4252,3226,2528,3973,2562,3002,2940,3038,2462,3670,4973,4627,5005,2706,3724,3481,4569,4155,3912,4536,4955,2749,4194,4583,4278,2744,2925,3466,4304,4598,2604,3625,3637,3675,3359,4807,3107,4741,2637,3439,3595,3432,4097,2924,4699,3316,4687,3978,2622,4216,3306,3371,3296,3793,3858,3166,3013,3907,3963,4281,4458,4531,4228,3244,4637,3176,2821,4622,4479,3111,4050,3910,3778,3418,4218,2649,2485,3839,2917,3399,3716,4825,4513,3556,2728,2933,4439,3794,5036,2915,2936,4375,4149,3083,2898,4248,2966,3890,4792,4017,4587,4450,3838,2539,4512,4295,2698,4934,3537,4001,3959,2587,2996,4721,3205,4270,4475,3290,3406,4171,4244,4009,3034,4164,3112,3437,2956,4900,4394,4619,3049,3507,2891,3844,2607,4540,5045,4731,3483,4897,2957,2826,3144,4413,4157,3329,3327,2981,5013,3965,3324,2753,4773,3784,2946,3763,4582,4315,4311,5031,4025,4655,3975,2520,2941,4591,2863,4586,2467,3998,3800,2952,2987,3072,4034,4848,4415,4519,3085,3518,4796,4958,4013,3666,4081,3470,3096,4819,4429,4221,4814,5046,2470,3892,4031,3496,4937,4693,4476,4538,5035,3828,4352,4786,2529,3071,3641,2530,3374,2596,3527,4251,4361,3150,4298,5033,3561,4147,3520,3734,3659,3135,3041,4075,3172,3268,4426,4011,3811,3905,4272,3130,3563,4430,4668,2544,4414,3352,3307,3647,3645,3639,4455,2988,2892,4733,3635,2513,3699,3806,2849,4379,4354,4663,4871,4123,2945,2736,3314,4859,3326,3924,4979,2931,3194,3616,2584,4489,4969,2567,4989,4036,3286,2463,2498,2506,3292,3840,2901,3927,4686,3932,3661,4070,4374,4675,4093,5030,2939,4564,3949,4357,2709,4343,3866,2999,3485,4860,2625,4084,3178,4767,4654,3788,2712,3255,3060,4510,2609,4638,2841,3318,4898,3380,3955,4385,4397,3632,3480,3376,3300,4758,4266,3488,2819,4875,2796,4524,3579,3494,3569,3164,3564,4823,2560,3615,3843,3201,4219,3242,3123,3469,2868,3776,3757,4521,4857,3420,3079,2563,4719,4841,3775,4063,3332,2690,2564,4233,4431,4817,4803,4309,3082,2879,4117,3764,4180,3293,4885,3676,4334,4259,4238,2703,4277,3000,3717,4730,3864,3897,4407,3266,4977,4832,4645,3206,4291,2838,4500,3429,4279,4406,2740,4757,4879,3214,2820,4850,4656,2867,3446,4981,4943,3993,2758,4432,3350,4639,4179,3086,4959,2989,3591,4246,4145,4160,3105,4305,4109,3808,3532,2760,4208,2930,3503,3336,4791,3449,4650,3852,4902,3261,2810,4043,4307,4162,4333,4880,2786,4082,2540,4118,3830,2694,2811,3753,4381,3633,2679,3199,4053,4448,4972,3044,3586,3495,3289,2620,4529,4423,4614,3232,2747,4887,4543,3558,4255,3570,3812,3412,4910,4683,2536,3200,2754,2807,3987,3109,3005,4961,4265,4911,4146,3929,4574,3948,2906,4605,3115,4667,3500,3055,3587,4542,3308,2494,4018,2522,5026,4079,3656,4495,4468,4992,3092,3170,4391,4991,4292,2923,4449,3947,3179,4844,4862,3276,3618,4589,3731,2659,4738,3450,3283,2618,3874,3744,4617,3674,4708,2655,2928,4809,2903,4735,3562,3531,3451,3305,3660,2927,5014,2639,3312,4798,4199,4606,3540,2859,3245,4494,3663,4557,3555,3423,4378,4165,2794,4284,4827,4231,5039,4632,3627,4954,3103,3772,4195,3581,3917,3173,2910,3263,4172,2816,3841,4086,3392,4161,2599,3384,3729,4918,2521,4364,4811,4365,2688,3280,3249,3421,4490,3804,2721,3391,3588,3798,3602,4471,5047,4187,4062,5034,4682,4022,3826,4300,3665,3934,3097,2526,3250,3372,4762,3876,4186,3523,3634,3078,4752,4497,2473,4151,3267,4607,4440,4119,3394,2885,3133,2884,2833,4128,3093,3797,3479,2493,3631,3114,3435,3966,4092,3703,3129,4454,2545,3842,4774,3906,2817,2684,2922,3939,3751,3171,4341,4239,2490,2880,2887,4652,4920,3047,3175,2800,2474,4498,3012,2724,4280,4306,4760,4592,2812,2781,4597,3458,4234,4438,4006,3873,4004,3551,3552,4545,2675,2970,3275,3779,4268,4909,3813,4775,3160,2893,2511,2504,3088,3970,3007,2480,3867,2850,2876,4211,2972,4532,3298,3048,3526,2864,2943,2585,4133,3547,4554,3353,3064,4178,2913,4130,2650,5040,2888,4012,3980,4812,4546,4409,4537,3958,4054,4213,4345,2896,4562,4942,3388,3967,3442,3529,3921,3721,3640,2788,4275,4101,4994,4462,2732,5002,3233,4747,3877,3649,3945,3650,2542,3941,2537,3157,4189,4380,2787,3457,4940,3832,4835,3185,4763,3491,3771,4901,3227,3087,3361,3614,3937,3673,3319,3908,3535,2793,2543,4286,4461,4283,3836,4021,2632,3235,3871,2907,3668,2582,4299,4986,4810,2629,4154,2853,4671,2716,2669,4290,3712,3192,3522,3989,4568,5038,2573,4249,3594,3617,4956,2636,4970,3125,2921,3781,3545,3234,2929,4176,4392,3198,3389,3938,3101,3916,4678,2658,4988,5020,3373,2666,3960,4508,4571,4484,3733,4896,4310,2589,3566,4550,4015,2714,3122,2517,5009,4073,2553,4768,3519,4402,3468,3120,4867,2866,2729,4853,3810,4175,4020,3755,2799,4023,4339,3743,3395,4114,3433,4224,2953,3204,4615,3441,4124,4445,3444,4200,3416,2611,3208,2835,3612,2515,2664,4129,2689,2572,4744,3402,4506,4829,3006,4256,4383,4884,3713,4335,2735,2509,4388,4080,3705,4401,3196,2701,5004,3820,3344,2847,4460,4152,3638,4596,2598,3054,4422,3021,4125,3256,3153,2775,3884,4849,3549,2959,4037,4759,4996,5016,2902,2613,4367,3022,2845,3992,5018,3220,4883,3030,4702,3403,3390,4772,2600,3254,4094,4267,3445,2822,4854,2478,3317,2829,3510,4548,3560,4222,3888,4227,3061,4593,2748,3831,4322,4729,5012,4520,3365,4570,2496,3749,3787,4038,3284,4612,2505,3513,4905,3603,3379,4008,4886,4229,2934,3780,3583,4604,2469,3870,4452,5029,5019,2918,3218,4833,2583,4999,3203,2597,2842,4085,2846,4851,2856,4312,2904,2944,4830,3008,4131,3605,3926,3207,3003,3270,3424,4688,2791,3846,2551,4329,4207,3033,4514,3909,3814,4369,4590,2831,2497,3454,3167,5008,3188,4635,2643,4740,5032,3063,3142,3898,3964,3651,4005,4968,3837,4371,4525,4676,2964,4666,4993,4868,3401,4350,3040,4610,2644,2603,3323,3051,4778,4997,2482,4852,2471,4990,2516,3742,3131,4047,4387,3629,3692,3630,3855,2965,2900,3304,3920,4779,3524,3028,4945,3335,4670,3889,3381,2512,2581,3550,4040,3669,3477,4487,4262,2663,3658,4188,3990,4052,3584,4720,3183,4104,4111,3212,3985,4697,3824,2547,3484,2773,3868,3368,3533,3759,3098,4024,4503,4595,3046,3681,3982,3169,2576,3258,3473,3431,3596,4103,3238,3121,4287,4515,4732,4933,2836,2963,4421,2908,2780,3148,3281,3696,4496,2626,2491,2686,3419,4257,4882,3438,4328,4174,3611,2705,4680,4220,4623,3070,4100,2978,4673,3478,2672,3684,3127,3138,3271,3117,2601,4467,4715,3291,3536,3467,3168,3770,4331,3976,5023,4907,4788,4736,3593,3493,2590,3592,4714,2848,4613,2704,3567,4787,2554,2634,3791,3397,2646,4965,4344,4504,3711,3969,3149,4696,3728,4225,2777,2660,4457,3672,4477,3039,2641,3278,3499,3598,2696,2823,3506,4903,2479,3991,4549,4424,5042,3385,2813,3053,4653,3691,4139,3606,4806,4739,3895,3559,4647,4247,3413,4935,4662,4976,2751,3578,2722,3827,4552,2685,4442,2739,2642,3805,2565,2500,3303,3786,3655,3210,4797,2871,3427,4872,4294,4106,2911,3330,4566,3872,2852,4889,2792,2967,4913,3134,4649,4755,3762,3217,4143,4952,4828,3398,3783,3140,3682,3956,3720,3542,3782,4420,3565,3448,4805,3573,4831,4205,4072,2861,2771,3739,3979,3741,2776,2468,4725,4599,4358,3607,3465,4669,4716,4491,2464,4932,2614,3923,4665,2532,3116,4362,2912,4658,3572,4099,2510,4713,3387,3718,2926,3163,4881,2519,4404,4076,4169,2947,2531,3062,3833,2676,3090,3881,4820,4998,3136,2761,4838,4045,3351,4581,3981,4560,2566,2489,3486,3700,4196,4077,3106,4501,4869,4258,3375,2998,3544,3538,4556,4474,4866,4712,2552,4308,2862,4939,4486,4321,2985,3930,4705,3222,2806,4672,2523,2484,3237,3621,2785,2889,4750,3847,4372,4873,2495,3582,2894,4108,4982,3377,3209,3974,4894,3997,2741,4781,3231,3349,2718,2828,4242,3878,3922,3141,2487,4159,4288,4588,4167,2878,3968,4071,3732,3489,2977,4029,3363,3333,4572,2561,4802,4633,3856,3662,4855,4390,2737,4055,3417,4405,4579,4297,3430,4492,4980,4856,3620,3774,2808,3686,2949,3126,2595,2992,4631,2774,2991,4170,4122,4836,4785,3697,2592,2579,2783,4173,4223,3548,4890,4923,3736,3299,3146,2640,3221,3190,5028,4482,3452,4058,3151,3408,2980,4625,2662,4679,3977,2602,4600,3915,3918,2673,3609,3750,4282,4089,3020,3557,2948,2916,3358,3257,4095,4789,3202,3460,2586,5003,2958,3875,4359,3719,4269,3285,3574,3698,3883,3068,3023,2875,3677,3302,4921,3848,2789,3646,4386,3067,3671,2824,4843,3818,3089,4616,3475,3821,3228,2488,3056,4756,3321,3154,3066,2757,4793,3512,2726,4727,5027,3896,4348,3476,4059,2610,2909,3501,4776,2974,3277,2502,3664,2798,2475,2914,3543,3104,5015,4142,4217,4765,2784,4403,2492,2764,3246,3355,3459,4516,4044,2665,2874,4899,3803,4363,3785,3626,3009,4066,4190,4575,3850,3236,3880,2881,4232,3597,4035,3754,3857,3042,2790,2801,4517,2870,3328,4761,3953,3777,4193,3073,4694,3919,3032,3322,4096,2628,2832,4007,3946,3411,4766,4544,3859,3701,3057,3667,4799,4644,3132,4601,4107,2768,3264,3752,4553,3996,3745,3081,3695,2683,4914,3492,4236,4746,3462,4105,4014,3553,4960,3984,3901,4878,4555,3853,3180,2687,3925,4473,4325,2968,4466,4710,3643,3147,2693,4824,2872,3426,4677,4847,4661,3422,4938,4472,3773,2503,2955,2725,2839,3337,2569,4936,3338,3124,4087,3690,4742,4264,4563,3622,4629,4734,4717,4138,4594,4643,4184,3025,4192,2954,4895,3590,5044,4398,3913,5006,3894,4451,3110,3320,2578,3715,3069,5007,2534,3642,2877,3215,4132,4700,3610,2648,3247,4927,2708,4444,2975,4584,3511,4181,3248,4340,5048,2769,4320,3310,4185,3879,3052,2700,3339,-1,25,79,7,7,12,1,79,71,77,58,73,13,71,29,31,25,62,29,0,90,12,101,57,25,86,37,100,10,75,97,25,98,73,29,4,80,31,23,79,10,4,35,31,29,7,7,30,73,65,69,17,10,77,69,12,77,30,79,7,98,67,5,8,60,20,92,69,3,2,25,82,68,52,26,17,29,27,98,11,73,67,15,77,7,82,0,73,85,10,7,17,12,12,73,5,120,249,79,81,29,83,120,79,10,1,73,26,91,30,23,160,86,10,103,4,12,82,60,94,8,23,25,73,40,2,24,5,23,28,12,33,95,2,27,79,31,6,79,14,1,10,23,70,37,7,65,48,14,63,19,65,7,7,30,79,65,16,25,29,0,83,27,75,90,22,8,12,40,0,14,30,79,14,75,6,1,22,65,3,90,7,77,30,68,79,82,79,12,73,8,99,75,69,11,82,102,43,75,82,7,37,65,73,2,99,12,91,19,77,24,25,27,24,73,80,69,67,24,79,75,103,79,99,127,6,10,24,25,73,27,79,24,8,79,82,120,2,75,62,100,23,79,101,77,4,79,27,27,0,11,77,29,127,14,27,86,7,23,83,250,67,14,15,35,29,25,6,92,27,0,19,28,27,15,12,35,9,227,69,8,2,47,29,16,77,125,31,75,69,27,58,73,71,59,28,95,0,6,14,13,3,31,8,120,79,82,40,14,127,27,91,70,77,71,73,89,23,92,49,40,27,226,73,75,6,0,87,65,12,14,29,6,97,75,79,30,23,0,69,6,1,2,31,98,25,44,29,23,3,103,4,25,23,207,75,12,11,27,92,4,25,45,100,6,11,73,77,13,2,3,10,12,73,3,47,20,10,96,92,77,8,28,66,65,98,27,79,100,73,102,3,8,82,8,34,6,15,29,77,75,92,5,75,0,183,19,60,46,186,2,31,8,22,56,71,103,12,64,79,96,6,29,62,82,96,0,101,31,12,6,8,82,1,3,148,4,66,82,82,35,79,23,77,26,28,15,13,71,7,71,96,90,79,34,31,65,25,77,97,67,98,99,29,7,14,61,82,84,77,1,82,27,42,98,24,12,61,169,79,75,120,247,73,67,69,7,19,82,73,12,79,25,22,8,8,31,65,91,23,28,23,93,10,26,69,75,29,10,5,69,8,82,57,11,67,127,10,25,33,95,65,5,62,155,11,22,77,101,4,73,77,80,79,155,79,9,73,18,57,73,64,73,0,69,28,4,1,14,3,92,70,81,5,0,6,82,46,84,73,77,5,68,23,26,41,15,179,80,29,10,79,7,32,103,226,26,16,77,23,7,0,61,22,28,75,59,8,11,83,19,13,91,10,82,24,0,75,10,239,10,23,89,11,2,12,14,65,2,29,6,71,6,6,29,170,29,125,80,79,63,70,77,79,29,6,80,1,2,3,34,3,90,77,6,77,67,27,12,2,157,79,7,30,28,75,14,7,10,0,23,49,23,73,8,27,70,27,2,111,46,12,14,29,28,3,65,67,31,77,7,82,20,101,81,14,12,149,44,73,67,1,59,27,46,19,1,30,5,73,31,94,14,120,5,19,79,23,2,24,24,12,12,12,2,40,8,69,27,11,64,11,72,1,25,25,8,25,27,77,27,29,250,101,19,5,254,67,31,73,66,31,6,14,82,73,2,7,73,2,65,61,8,77,59,120,13,58,49,69,29,70,75,79,0,12,79,58,6,10,97,26,67,82,15,6,14,8,20,116,23,29,4,58,75,82,47,12,8,27,2,75,0,29,27,79,12,2,10,12,42,39,7,0,72,10,98,4,25,1,28,102,251,39,27,2,102,43,46,20,0,52,99,29,109,75,73,92,15,28,12,14,127,77,9,82,25,23,68,10,9,82,102,77,24,82,37,14,75,2,10,34,1,31,14,3,27,70,23,107,14,10,8,10,14,69,27,31,18,11,71,40,23,82,75,36,12,73,6,1,101,64,52,0,77,82,29,33,14,97,6,29,71,227,77,27,19,75,5,10,4,66,68,73,73,5,92,14,38,30,56,90,30,4,19,65,2,196,82,10,171,69,45,31,10,8,19,13,32,29,29,25,1,44,11,60,199,19,10,75,2,39,59,90,14,8,77,79,23,92,29,29,25,29,27,8,70,69,93,23,61,27,92,81,14,75,25,0,2,0,8,6,12,79,2,27,29,77,56,127,26,65,69,2,42,1,25,10,24,23,38,2,10,1,8,26,12,33,94,2,13,2,95,32,26,0,10,40,7,9,7,79,14,6,27,8,31,75,69,69,26,67,15,30,14,5,24,14,19,82,29,73,34,0,75,7,77,251,29,23,1,30,77,25,28,14,2,5,161,68,4,4,150,17,8,59,97,37,16,42,1,52,8,8,12,83,37,29,28,23,11,22,8,12,75,17,0,26,27,92,69,6,73,73,27,100,84,79,29,14,75,71,12,6,8,73,1,79,1,79,5,10,6,10,4,77,4,95,25,59,75,5,49,9,9,77,92,79,57,6,14,27,89,73,73,22,14,67,14,14,28,8,10,73,5,119,90,87,7,10,8,4,2,47,79,27,62,4,98,13,31,49,10,6,6,12,28,7,0,10,40,7,25,144,64,6,75,79,75,93,2,12,6,75,4,4,4,67,140,4,82,75,12,3,75,75,0,14,75,4,29,34,27,63,30,13,25,82,11,24,12,0,34,191,82,17,13,13,77,29,77,77,33,73,30,10,6,73,77,47,82,62,96,77,0,14,23,59,6,88,25,1,79,27,31,31,27,73,108,77,2,4,9,5,161,127,0,77,12,79,8,82,39,97,28,25,203,69,14,82,21,98,62,8,73,2,36,75,17,77,2,10,12,20,82,5,27,96,77,12,44,79,60,16,59,10,2,79,31,93,34,82,79,31,39,69,61,30,19,75,91,3,27,73,71,27,27,0,44,12,28,48,5,7,73,31,67,47,7,11,65,13,8,10,24,67,41,79,12,79,120,120,14,27,9,0,14,71,35,2,5,77,48,26,31,57,31,79,4,17,6,0,12,12,25,49,82,69,94,217,14,44,10,73,71,10,79,35,12,75,97,10,32,39,82,28,6,27,69,41,65,47,29,75,82,23,75,46,3,77,103,19,73,31,24,14,14,67,11,4,28,14,90,23,4,31,24,80,31,67,31,28,1,1,10,80,92,64,79,61,79,0,12,29,92,100,14,12,80,11,26,27,6,12,75,82,71,73,25,56,77,31,0,77,12,77,71,28,29,187,2,7,19,25,30,26,3,2,29,2,25,31,14,73,190,8,82,29,7,25,31,36,79,70,75,67,69,82,100,24,12,83,75,73,31,81,2,66,77,14,27,36,4,27,3,28,23,97,12,14,23,37,24,25,15,92,60,8,92,12,69,49,10,6,14,80,22,14,102,120,2,19,79,98,58,68,8,12,14,67,90,101,14,29,57,77,27,14,7,12,26,17,120,26,75,175,5,30,20,102,73,82,86,67,2,28,61,2,7,102,8,25,28,12,0,4,75,82,40,30,23,77,0,37,2,7,73,26,31,31,7,0,19,0,94,3,75,7,77,30,75,77,12,79,127,12,14,73,14,21,47,91,12,8,62,10,58,28,73,2,8,0,13,44,10,95,85,60,70,99,79,103,82,7,4,28,66,4,73,30,47,0,0,70,23,73,5,6,29,23,101,19,100,75,39,1,73,46,3,75,4,29,67,6,82,10,97,5,0,77,29,73,69,69,5,57,89,82,2,4,69,9,66,31,27,9,173,92,75,23,2,31,23,65,2,67,1,60,0,0,14,0,29,7,67,80,12,8,77,103,75,40,73,29,10,10,34,1,3,97,69,1,73,73,60,73,77,22,51,77,90,127,2,13,19,27,79,13,3,71,75,27,12,7,46,3,31,27,27,4,60,29,0,6,61,18,19,70,2,127,25,213,2,77,13,67,8,69,24,6,73,79,22,4,63,31,23,82,23,14,11,31,56,24,6,79,203,10,2,68,75,19,29,0,67,1,79,22,96,100,8,77,75,14,99,10,1,11,73,10,14,69,1,4,26,10,14,71,30,15,14,69,5,4,61,58,8,14,77,79,12,4,0,151,75,59,0,82,19,99,10,22,73,73,77,48,79,3,8,75,77,66,11,1,100,99,75,39,19,92,57,84,27,49,28,79,5,82,19,75,31,6,0,4,8,25,14,27,220,12,99,14,14,4,6,29,77,17,2,12,25,48,221,75,7,8,25,127,33,26,0,91,29,10,5,31,16,137,35,136,23,12,32,79,4,22,11,10,7,97,6,62,77,6,44,8,70,15,6,34,2,14,39,12,82,102,10,145,82,75,24,2,83,14,91,42,30,75,49,73,2,66,82,1,0,3,33,3,79,9,126,12,27,30,12,65,56,13,5,0,31,7,11,14,67,29,12,8,67,4,9,0,12,92,7,75,14,82,6,14,29,10,29,2,8,10,167,31,79,45,19,0,5,99,10,34,93,8,2,100,14,2,20,60,79,96,20,15,59,14,82,82,0,27,54,103,10,0,8,73,22,3,19,35,71,5,14,101,8,65,253,190,66,0,19,4,1,30,25,12,12,29,31,87,82,25,8,4,7,70,101,67,31,23,9,14,92,7,61,1,1,79,127,30,14,34,70,10,0,77,73,8,99,24,0,25,8,44,2,10,27,4,73,83,30,60,31,10,17,147,28,67,40,1,79,14,10,27,90,8,37,29,27,6,4,22,1,75,19,1,82,12,1,29,82,126,33,27,12,75,79,3,28,37,28,12,0,26,6,73,73,96,8,3,44,60,77,73,1,77,25,73,30,5,29,71,77,29,92,9,36,28,0,4,75,36,99,29,27,79,67,24,7,97,62,4,34,10,14,28,2,6,25,32,38,82,85,75,19,31,33,75,14,8,8,19,7,34,30,3,68,79,4,69,79,28,73,19,73,35,1,75,33,31,67,67,85,28,66,55,61,3,10,9,24,82,0,23,23,25,75,84,26,63,57,73,44,92,73,38,4,161,2,10,120,15,73,10,24,82,79,1,25,29,75,255,75,79,23,19,71,27,17,25,23,25,5,8,10,64,1,41,2,34,23,10,6,14,82,73,96,98,46,75,164,77,86,10,27,30,77,25,5,73,61,77,49,82,0,86,5,12,9,12,77,34,82,27,2,77,25,0,79,19,14,10,71,12,31,15,43,25,31,6,8,84,10,24,22,14,7,23,2,77,14,13,4,58,4,12,77,56,2,12,27,71,14,82,65,36,98,2,79,8,6,27,73,14,1,65,2,5,37,99,79,73,73,57,4,86,10,26,14,8,12,1,77,127,6,10,7,99,20,61,18,10,31,8,11,37,10,79,10,94,73,40,89,66,7,4,102,29,8,8,79,242,19,42,73,77,3,12,82,10,7,5,59,6,2,31,12,77,82,69,27,2,39,7,9,63,31,82,91,7,4,33,29,56,12,6,11,3,35,62,17,79,67,4,34,25,17,45,8,25,14,6,14,28,8,8,4,25,64,1,10,25,31,1,36,94,36,27,31,7,75,8,145,191,25,24,12,14,83,29,0,100,3,23,28,75,28,27,67,10,77,35,0,24,29,59,23,120,25,47,65,82,71,27,189,7,16,29,4,19,63,12,6,70,27,42,92,92,127,75,6,12,30,92,72,28,14,94,31,73,127,75,5,103,17,80,25,28,27,85,32,5,39,197,10,75,75,77,1,7,14,31,96,96,61,29,30,120,92,10,100,77,12,25,62,57,98,79,5,79,29,8,101,3,100,25,14,65,79,7,5,110,6,0,77,6,77,29,8,30,57,12,14,23,19,4,2,82,77,0,79,31,69,0,10},key))if a then a()else print("WRONG PASSWORD!")end
