`timescale 1ns/10ps

module stopwatch(
iCLK,
iRESETn,
start,
stop,
lap_store
);

input iCLK;
input iRESETn;
input start;
input stop;
input lap_store;
  

fdaparameter IDLE	=	0;
parameter RUN	=	1;
parameter STOP	=	2;
parameter Lap_Time_Store	=	3;
parameter RESET	=	4;

parameter MAX_SUB_SEC =	8'd100;
parameter MAX_SEC	=	7'd60;
parameter MAX_MIN	=	7'd60;
parameter MAX_HOUR	=	8'd100;
          
reg pre_state;
reg const;
reg [3:0] curr_state;
reg [3:0] next_state;


reg [6:0] sub_sec;
reg [5:0] sec;
reg [5:0] min;
reg [6:0] hour;

wire g_10ms;
          
always @(*) begin
  
pre_state = (const) == 1 ? RUN : STOP;

  case(curr_state)
        
    IDLE    :   begin
                    if(start)
                      next_state  <= RUN;
                    else
                      next_state  <= IDLE;                    
                end
    
    
    RUN    :   begin
                    if(lap_store) begin
                      next_state  <= Lap_Time_Store;
                      const <= 1;
                    end
                    else if(stop)
                      next_state  <= STOP;
                    else
                      next_state  <= RUN;                      
                end
            
  
    STOP    :   begin
                   if(lap_store) begin
                      next_state  <= Lap_Time_Store;
                      const <= 0;
                  end
                    else if(start)
                      next_state  <= RUN;
                    else
                      next_state  <= STOP;
                end
      
              
    Lap_Time_Store    :   begin
                              if(curr_state)
                                 next_state  <= pre_state;
                              else
                                 next_state  <= pre_state;                      
                           end
                           
                        
    RESET    :   begin
                    
                    next_state <= IDLE;
                  
                 end
                 
    default : next_state  <= IDLE;
    
  endcase

     
end

/* always @(posedge iCLK or negedge iRESETn) begin
  if(!iRESETn)
    curr_state  <= IDLE;
  else
    curr_state  <= next_state;
end

always @(posedge iCLK or negedge iRESETn) begin
  if(!iRESETn) begin
                  sig_1 <= 0;
                  sig_2 <= 0;
                  sig_3 <= 0;
                  sig_4 <= 0;
                  sig_5 <= 0;
  end
  
  else
    case(curr_state)
      
      IDLE    :   begin
                    sig_1 <= 1;
                    sig_2 <= 0;
                    sig_3 <= 0;
                    sig_4 <= 0;
                    sig_5 <= 0;
                  end
         
         
      RUN    :   begin
                    sig_1 <= 0;
                    sig_2 <= 1;
                    sig_3 <= 0;
                    sig_4 <= 0;
                    sig_5 <= 0;
                    
                    
      STOP    :   begin
                    sig_1 <= 0;
                    sig_2 <= 0;
                    sig_3 <= 1;
                    sig_4 <= 0;
                    sig_5 <= 0;
                  end
                  
                  
      Lap_Time_Store    :   begin
                              sig_1 <= 0;
                              sig_2 <= 0;
                              sig_3 <= 0;
                              sig_4 <= 1;
                              sig_5 <= 0;
                            end
                    
                    
      RESET    :   begin
                    sig_1 <= 0;
                    sig_2 <= 0;
                    sig_3 <= 0;
                    sig_4 <= 0;
                    sig_5 <= 1;
                    end
                                              
      default :   begin
                    sig_1 <= sig_1;
                    sig_2 <= sig_2;
                    sig_3 <= sig_3;
                    sig_4 <= sig_4;
                    sig_5 <= sig_5;
                  end
    endcase
end  */


//sub_sec//
always@(posedge iCLK or negedge iRESETn) begin
  
	if(!iRESETn)
		sub_sec <= 0;
		
	else if (curr_state == RESET)
		sub_sec <= 0;
		
	else if ( ( (curr_state == RUN) | (curr_state == Lap_Time_Store) ) & g_10ms )
		
		if(sub_sec == MAX_SUB_SEC - 1) begin
			sub_sec	<= 0;
			sec  <= sec + 1;
			end
		else
			sub_sec	<= sub_sec + 1;
			
	else
		sub_sec <= sub_sec;
end

//sec//
always@(posedge iCLK or negedge iRESETn) begin
  
	if(!iRESETn)
		sec <= 0;
		
	else if (curr_state == RESET)
		sec <= 0;
		
	else if ( ( (curr_state == RUN) | (curr_state == Lap_Time_Store) ) & (sub_sec == MAX_SUB_SEC - 1) )
		
		if(sec == MAX_SEC - 1) begin
			sec	<= 0;
			min  <= min + 1;
			end
		else
			sec	<= sec + 1;
	
	else
		sec <= sec;
end

//min//
always@(posedge iCLK or negedge iRESETn) begin

	if(!iRESETn)
		min <= 0;
	
	else if (curr_state == RESET)
		min <= 0;
	
	else if ( ( (curr_state == RUN) | (curr_state == Lap_Time_Store) ) & (sub_sec == MAX_SUB_SEC - 1) & (sec == MAX_SEC - 1) )
	
		if(min == MAX_MIN - 1) begin
			min	<= 0;
			hour <= hour + 1;
			end
		else
			min	<= min + 1;
	
	else
		min <= min;
end


//hour//
always@(posedge iCLK or negedge iRESETn) begin
	
	if(!iRESETn)
		hour <= 0;
	
	else if (curr_state == RESET)
		hour <= 0;
	
	else if ( ( (curr_state == RUN) | (curr_state == Lap_Time_Store) ) & (sub_sec == MAX_SUB_SEC - 1) & (sec == MAX_SEC - 1) & (min == MAX_MIN - 1) )
		
		if(hour == MAX_HOUR - 1)
			hour	<= 0;
		else
			hour	<= hour + 1;
	
	else
		hour <= hour;
end

endmodule

