//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm


	enum logic [1:0] {
		st_idle		 	 = 2'b00,
		wait_c_res	 	 = 2'b01,
		st_wait_bc_res	 = 2'b10,
		st_wait_abc_res  = 2'b11
	} state, next_state;
	
	always_comb
		begin
			next_state  = state;

			isqrt_x_vld = '0;
			isqrt_x     = 'x;  // Don't care

			case (state)
				st_idle:
					begin
						isqrt_x = c;

						if (arg_vld)
							begin
								isqrt_x_vld = '1;
								next_state  = wait_c_res;
							end

						end
				wait_c_res:
					begin
						isqrt_x = isqrt_y + b;

						if (isqrt_y_vld)
							begin
								isqrt_x_vld = '1;
								next_state  = st_wait_bc_res;
							end
					end

				st_wait_bc_res:
					begin
						isqrt_x = isqrt_y  + a;
	
						if (isqrt_y_vld)
							begin
								isqrt_x_vld = '1;
								next_state  = st_wait_abc_res;
							end
					end

				st_wait_abc_res:
					begin
						if (isqrt_y_vld)
							begin
								next_state = st_idle;
							end
					end
			endcase		
		end
		
    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;		


    //------------------------------------------------------------------------
    // Accumulating the result

    always_ff @ (posedge clk)
        if (rst) begin
            res_vld <= '0;
			res		<= '0;
        end else begin
            res_vld <= (state == st_wait_abc_res & isqrt_y_vld);
			res <= isqrt_y;	
		end

endmodule
