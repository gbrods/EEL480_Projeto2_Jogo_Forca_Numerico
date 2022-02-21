-- Declaração de bibliotecas:
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY jogo_forca IS
    PORT(
        G_CLOCK_50 : IN  STD_LOGIC;                     -- Clock de 50 MHz
        V_SW       : IN  STD_LOGIC_VECTOR(12 DOWNTO 0); -- Switches da placa FPGA
        V_BT       : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);  -- Botões da placa FPGA
        G_LEDG     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);  -- LEDs verdes
        G_LEDR     : OUT STD_LOGIC_VECTOR(17 DOWNTO 0); -- LEDs vermelhos
        G_HEX0, G_HEX1, G_HEX2, G_HEX3, G_HEX4, G_HEX5, G_HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) -- Displays de 7 segmentos
        );
        
END jogo_forca; 

ARCHITECTURE behavioral OF jogo_forca IS

TYPE states IS (start_game, waiting_word, win_game, game_over);
SIGNAL current_state, next_state : states;

SIGNAL acerto : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL erro : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL dificuldade, vidas : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL win, lose : STD_LOGIC;

BEGIN

PROCESS(G_CLOCK_50, V_BT) 
BEGIN
------------------------------------------------------------------------------------------------------
--- Processo que realiza a transição do estado atual para o próximo estado

    IF V_BT(0) = '0' THEN 
        current_state <= start_game; -- Estado inicial
	 
	ELSIF rising_edge(G_CLOCK_50) THEN        
        current_state <= next_state; -- Mudança de estado	 	

	END IF;
END PROCESS;

--- Fim do processo
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
--- Início da máquina de estados

PROCESS(current_state, dificuldade, acerto, erro, V_SW, vidas)
BEGIN

	CASE current_state IS
        
        WHEN start_game => -- Sinais são zerados ao iniciar ou reiniciar o jogo
            acerto <= "000000";
            erro <= "0000";
            win <= '0';
			lose <= '0';

            IF (V_SW(11) = '1') THEN -- Escolhendo a palavra secreta fácil: 024689
				dificuldade <= "01";
				vidas <= "11";
				next_state <= waiting_word;
            
            ELSIF (V_SW(12) = '1') THEN -- Escolhendo a palavra secreta difícil: 751394
                dificuldade <= "10";
				vidas <= "11";
				next_state <= waiting_word;
            
			ELSE
			    next_state <= start_game;
			
			END IF;
        
		WHEN waiting_word =>
		    IF (vidas = "00") THEN -- Se as vidas acabarem:
                next_state <= game_over;
			        
            ELSIF (acerto = "111111") THEN -- Se todas as palavras foram descobertas:
                next_state <= win_game;				        
			   
			ELSE
		        -- Modo fácil: 024689
                IF (dificuldade = "01") THEN
                
			        IF (V_SW(0) = '1' AND acerto(5) = '0') THEN 
			            acerto(5) <= '1';			        
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(2) = '1' AND acerto(4) = '0') THEN
	                    acerto(4) <= '1';		    
						next_state <= waiting_word;
			        
			        ELSIF (V_SW(4) = '1' AND acerto(3) = '0') THEN
                        acerto(3) <= '1';			        
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(6) = '1' AND acerto(2) = '0') THEN
                        acerto(2) <= '1';			    
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(8) = '1' AND acerto(1) = '0') THEN
                        acerto(1) <= '1';			        
			            next_state <= waiting_word;	
			        
			        ELSIF (V_SW(9) = '1' AND acerto(0) = '0') THEN
                        acerto(0) <= '1';			    
			            next_state <= waiting_word;				        
			        
                    ELSIF (V_SW(1) = '1' AND erro(0) = '0') THEN
                        erro(0) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(3) = '1' AND erro(1) = '0') THEN
                        erro(1) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(5) = '1' AND erro(2) = '0') THEN
                        erro(2) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(7) = '1' AND erro(3) = '0') THEN
                        erro(3) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word; 
                    
                    ELSE
                        next_state <= waiting_word;                        
                    END IF;
                
                -- Modo difícil: 751394
                ELSIF (dificuldade = "10") THEN
                
			        IF (V_SW(7) = '1' AND acerto(5) = '0') THEN
			            acerto(5) <= '1';			        
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(5) = '1' AND acerto(4) = '0') THEN
	                    acerto(4) <= '1';		    
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(1) = '1' AND acerto(3) = '0') THEN
                        acerto(3) <= '1';			        
			            next_state <= waiting_word;
			        
			        ELSIF (V_SW(3) = '1' AND acerto(2) = '0') THEN
                       acerto(2) <= '1';			    
			           next_state <= waiting_word;
			        
			        ELSIF (V_SW(9) = '1' AND acerto(1) = '0') THEN
                       acerto(1) <= '1';			        
			           next_state <= waiting_word;	
			        
			        ELSIF (V_SW(4) = '1' AND acerto(0) = '0') THEN
                       acerto(0) <= '1';			    
			           next_state <= waiting_word;	  
			            
                    ELSIF (V_SW(0) = '1' AND erro(0) = '0') THEN
                        erro(0) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(2) = '1' AND erro(1) = '0') THEN
                        erro(1) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(6) = '1' AND erro(2) = '0') THEN
                        erro(2) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;
                    
                    ELSIF (V_SW(8) = '1' AND erro(3) = '0') THEN
                        erro(3) <= '1';
                        vidas <= vidas - 1;
                        next_state <= waiting_word;  
                        
                    ELSE
                        next_state <= waiting_word;
			        END IF;
                END IF;
            END IF;
        
        WHEN win_game =>   
            win <= '1';
            next_state <= win_game;
            
        WHEN game_over => 
            lose <= '1';
            next_state <= game_over;
            
    END CASE;
END PROCESS;

--- Fim da máquina de estados
------------------------------------------------------------------------------------------------------
    
------------------------------------------------------------------------------------------------------
--- Processo que configura as condições para acender os displays e leds:

PROCESS(current_state, dificuldade, acerto, vidas, win, lose)
BEGIN    

    IF (current_state = start_game) THEN -- Não deve acender nada antes de selcionar a dificuldade
        G_HEX6 <= "1111111";
        G_HEX5 <= "1111111";
        G_HEX4 <= "1111111";
        G_HEX3 <= "1111111";
        G_HEX2 <= "1111111";
        G_HEX1 <= "1111111";
        G_HEX0 <= "1111111";
        G_LEDG <= "000";
        G_LEDR <= "000000000000000000";
    
    ELSE 
    -- Para qualquer outro estado que não seja o start_game:
    
        -- Mostrando G no display G_HEX6 para as duas dificuldades
        IF win = '1' THEN
        
            CASE win IS
                WHEN '1' => G_HEX6 <= "0000010"; -- mostra G
                WHEN OTHERS => G_HEX6 <= "1111111"; -- display apagado
            END CASE;
        
        -- Mostrando P no display G_HEX6 para as duas dificuldades
        ELSIF lose = '1' THEN
        
            CASE lose IS
                WHEN '1' => 
                    G_HEX6 <= "0001100"; -- mostra P
                    G_LEDR <= "111111111111111111"; -- leds vermelhos acesos   
            
                WHEN OTHERS =>
                    G_HEX6 <= "1111111"; -- display apagado
                    G_LEDR <= "000000000000000000"; -- leds vermelhos apagados
            END CASE;
        
        -- Se o jogo não tiver terminado, o display G_HEX6 permanece apagado.
        ELSE
            G_HEX6 <= "1111111"; -- display apagado   
            G_LEDR <= "000000000000000000"; -- leds vermelhos apagados
        END IF;
        
        -- Mostrando as vidas nos leds verdes para as duas dificuldades        
        CASE vidas IS 
            WHEN "11" => G_LEDG <= "111";
            WHEN "10" => G_LEDG <= "011";
            WHEN "01" => G_LEDG <= "001";
            WHEN OTHERS => G_LEDG <= "000";
        END CASE;         

        -- Mostrando palavras corretas nos displays para o modo fácil: 024689
        IF (dificuldade = "01") THEN
        
            CASE acerto(5) IS
                WHEN '1' => G_HEX5 <= "1000000"; -- mostra 0
                WHEN OTHERS => G_HEX5 <= "1110111";   -- palavra oculta
            END CASE;
        
            CASE acerto(4) IS
                WHEN '1' => G_HEX4 <= "0100100"; -- mostra 2
                WHEN OTHERS => G_HEX4 <= "1110111";   -- palavra oculta
            END CASE;
        
            CASE acerto(3) IS
                WHEN '1' => G_HEX3 <= "0011001"; -- mostra 4
                WHEN OTHERS => G_HEX3 <= "1110111";   -- palavra oculta
            END CASE;        
        
            CASE acerto(2) IS
                WHEN '1' => G_HEX2 <= "0000010"; -- mostra 6
                WHEN OTHERS => G_HEX2 <= "1110111";   -- palavra oculta
            END CASE;                
            
            CASE acerto(1) IS
                WHEN '1' => G_HEX1 <= "0000000"; -- mostra 8
                WHEN OTHERS => G_HEX1 <= "1110111";   -- palavra oculta
            END CASE;                
                
            CASE acerto(0) IS
                WHEN '1' => G_HEX0 <= "0010000"; -- mostra 9
                WHEN OTHERS => G_HEX0 <= "1110111";   -- palavra oculta
            END CASE;   
        
        -- Mostrando palavras corretas nos displays para o modo difícil: 751394
        ELSIF (dificuldade = "10") THEN
            
            CASE acerto(5) IS
                WHEN '1' => G_HEX5 <= "1111000"; -- mostra 7
                WHEN OTHERS => G_HEX5 <= "1110111";   -- palavra oculta
            END CASE;
            
            CASE acerto(4) IS
                WHEN '1' => G_HEX4 <= "0010010"; -- mostra 5
                WHEN OTHERS => G_HEX4 <= "1110111";   -- palavra oculta
            END CASE;
            
            CASE acerto(3) IS
                WHEN '1' => G_HEX3 <= "1111001"; -- mostra 1
                WHEN OTHERS => G_HEX3 <= "1110111";   -- palavra oculta
            END CASE;        
            
            CASE acerto(2) IS
                WHEN '1' => G_HEX2 <= "0110000"; -- mostra 3
                WHEN OTHERS => G_HEX2 <= "1110111";   -- palavra oculta
            END CASE;                
                
            CASE acerto(1) IS
                WHEN '1' => G_HEX1 <= "0010000"; -- mostra 9
                WHEN OTHERS => G_HEX1 <= "1110111";   -- palavra oculta
            END CASE;                
                
            CASE acerto(0) IS
                WHEN '1' => G_HEX0 <= "0011001"; -- mostra 4
                WHEN OTHERS => G_HEX0 <= "1110111";   -- palavra oculta
            END CASE;           
        END IF;
    END IF;
END PROCESS;

--- Fim do processo
------------------------------------------------------------------------------------------------------

END behavioral;
