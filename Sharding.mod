/*********************************************
 * OPL 12.9.0.0 Model
 * Author: nouroudine
 * Creation Date: Nov 12, 2019 at 1:31:33 AM
 *********************************************/
/*********************************************
 * OPL 12.9.0.0 Model
 * Author: nouroudine
 * Creation Date: Nov 10, 2019 at 6:47:48 AM
 *********************************************/
int NumNodes = ...;
range Nodes = 1..NumNodes; 

// Get the supply (positive) and demand (negative)
// at each node
int SupDem[ Nodes ] = ...;

// Create a record to hold information about each arc
tuple arc { 

	key int fromnode; 
	key int tonode;
	float cost;
}

tuple proof_size {
	int p_1; 
}

// Get the set of arcs
{arc} Arcs = ...;
//SupDem = [ Node ];
float ArcsCost[ Nodes ][ Nodes ]; 
proof_size proof[ Nodes ]; 
range shard = 1..50; 
range shard_1  = 51..100;
range shard_2 = 101..151; 
range shard_3 = 152..203;
{arc} shard_arcs;
{arc} shard_arcs_1;
{arc} shard_arcs_2;
{arc} shard_arcs_3;

int SupDem_shard[ shard ] = ...; 
int SupDem_shard_1 [ shard_1 ] = ...;
int SupDem_shard_2[ shard_2 ] = ...;
int SupDem_shard_3[ shard_3 ] = ...;

execute { 

	// Compute the costn to traverse 
	// a specific node
	function ComputeCost( proof_1, proof_2 ) {	
	 	 return ( 0.5 ) * ( proof_1.p_1 + proof_2.p_1 + 1 ); 	
	}
	 
	// Randomly assign proof size
	// to nodes
	for( var i in  Nodes ) {	 
	 	proof[ i ].p_1 = Opl.rand(100);
	}	
	 
	 // Store the processing cost
	 // at in 2D array. 
	 // The cost would be calculated at each connected 
	 // node in the network. If there is not
	 // a connection between the nodes the cost would be zero 
	for( var n in Arcs) {
	 	ArcsCost[ n.fromnode ][ n.tonode ] = ComputeCost( proof[ n.fromnode ], proof[ n.tonode ] );		
	}
	
	// Creation of the first
	// shard arcs from its
	// disjoint set of nodes 
	for( var i in shard ) {	
		for( n in Arcs ) {
			if( i == n.fromnode ) {
				 shard_arcs.add( i, n.tonode, n.cost );
			
			if( i == n.tonode ) {				
				shard_arcs.add( fromnode, i, n.cost );			
			}					
		}		
	 }
    }
    
    // Create of the second
    // shard from its disjoint
    // set of nodes
    for( var i in shard_1 ) {	
		
		for( n in Arcs ) {
			if( i == n.fromnode ) {
				 shard_arcs_1.add( i, n.tonode, n.cost );
				 
			if( i == n.tonode ) {				
				shard_arcs_1.add( fromnode, i, n.cost );			
			}					
		}		
	 }
    }
    
    // Create of the third
    // shard shard from its 
    // disjoint set fo nodes
    for( var i in shard_2 ) {	
		
		for( n in Arcs ) {
			if( i == n.fromnode ) {
				 shard_arcs_2.add( i, n.tonode, n.cost );
				 
			if( i == n.tonode ) {				
				shard_arcs_2.add( fromnode, i, n.cost );			
			}					
		}		
	 }
    }
    
    // Creation of the four shard
    // from its disjoint set of nodes
    for( var i in shard_3 ) {	
		for( n in Arcs ) {
			if( i == n.fromnode ) {
				 shard_arcs_3.add( i, n.tonode, n.cost );
			if( i == n.tonode ) {				
				shard_arcs_3.add( fromnode, i, n.cost );			
			}					
		}		
	 }
    }
    
    // Since source and destination would randomly 
    // chosen, this function is making there
    // within the right interval
    function CheckBoundaries( low_bound, upper_bound ) { 
    	  
    	   var rand_value = Opl.rand(upper_bound);
    	   
    	   while( rand_value < low_bound || rand_value > upper_bound ){
    	   		
    	   		rand_value = Opl.rand(upper_bound); 	   
    	   }
    	   
    	   return rand_value;
  	}	    
  	
  	// Check the supply and demand are not the same
  	// Otherwise, do recomputation of one of them
  	function CheckSupplyDemand( supply_node, demand_node, low_bound,  upper_bound ) {
  		
  		 var require_node = supply_node;
  		 while( supply_node == demand_node ) { 
  		 
  		 		require_node = CheckBoundaries( low_bound, upper_bound );  
    	 }  		 
    	 
    	 return require_node;
  	}
  	 
    // Main Network
	var supply_node = Opl.rand(NumNodes);	
	
	 // Shard_ 0
	var supply_node_shard= Opl.rand( 50 );
	
	// Supply for Shard_1
	var supply_node_shard_1 = CheckBoundaries( 51, 100 );
	
	
	// Supply for Shard_2
	var supply_node_shard_2 = CheckBoundaries( 101, 151 );

	
	// Supply  for Shard_3
	var supply_node_shard_3 = CheckBoundaries( 152, 203 );
	

	// Demand for the main network 
	var demand_node = Opl.rand(NumNodes);
	
	while( supply_node == demand_node ) {	
		  demand_node_shard = Opl.rand(NumNodes);		
	}
	
	// Demand for Shard_0
 	var demand_node_shard = Opl.rand(50);
 	
	while( demand_node_shard == supply_node_shard ) {	
			demand_node_shard = Opl.rand(50);
	}

	// Demand for Shard_1
	var demand_node_shard_1 = CheckBoundaries(51, 100);
	if( demand_node_shard_1 == supply_node_shard_1 ) { 
		demand_node_shard_1 = CheckSupplyDemand( demand_node_shard_1, supply_node_shard_1, 51, 100 ); 
	}	
	
	// demand_node_shard_1 = demand_node_shard_1 + 20;
	
	// Demand  for Shard_2
	var demand_node_shard_2 = CheckBoundaries(101, 151) ;
	
	while( demand_node_shard_2 == supply_node_shard_2 || Opl.abs( supply_node_shard_2 - demand_node_shard_2 ) < 7 ) { 
		demand_node_shard_2 = CheckSupplyDemand( demand_node_shard_2, supply_node_shard_2, 101, 151 );
	}	
	
	// Demand for Shard_3 
	var demand_node_shard_3 = CheckBoundaries(152, 203) ;
	if( demand_node_shard_3 == supply_node_shard_3 ) { 
		demand_node_shard_3 = CheckSupplyDemand( demand_node_shard_1, supply_node_shard_1, 152, 203 );
	}	
	
	// Main network
	SupDem[ supply_node ] = 1;
	SupDem[ demand_node ] = -1;
	
	ArcsCost[ supply_node ][ supply_node ] == 0; 
	ArcsCost[ demand_node ][ demand_node ] == 0;
	
	// shard_0
	SupDem_shard[ supply_node_shard ] = 1;
	SupDem_shard[ demand_node_shard ] = -1;
	
	ArcsCost[ supply_node ][ supply_node_shard ] == 0; 
	ArcsCost[ demand_node ][ demand_node_shard ] == 0;
	
	// shard_1
	SupDem_shard_1[ supply_node_shard_1 ] = 1;
	SupDem_shard_1[ demand_node_shard_1 ] = -1;
	
	ArcsCost[ supply_node_shard_1 ][ supply_node_shard_1 ] == 0; 
	ArcsCost[ demand_node_shard_1 ][ demand_node_shard_1 ] == 0;
 	
 	// shard_2 
 	SupDem_shard_2[ supply_node_shard_2 ] = 1;
	SupDem_shard_2[ demand_node_shard_2 ] = -1;
	
	ArcsCost[ supply_node_shard_2 ][ supply_node_shard_2 ] == 0; 
	ArcsCost[ demand_node_shard_2 ][ demand_node_shard_2 ] == 0;
	
	// shard_3 
	SupDem_shard_3[ supply_node_shard_3 ] = 1;
	SupDem_shard_3[ demand_node_shard_3 ] = -1;
	
	ArcsCost[ supply_node_shard_3 ][ supply_node_shard_3 ] == 0; 
	ArcsCost[ demand_node_shard_3 ][ demand_node_shard_3 ] == 0;
	
}

/*
dvar boolean path[ Arcs ];
dexpr float CCPT = sum( < i, j, fcost > in Arcs ) ArcsCost[ i ][ j ] * path[ < i, j, fcost > ] * fcost; 

minimize CCPT;

subject to {
		
	// Preserve flows at each node.
	forall( i in Nodes )	
		ctNodeFlow:		
		 	sum( < i, j, fcost > in Arcs ) path[ < i, j, fcost  > ]
	 	 -  sum( < j, i, fcost > in Arcs ) path[ < j, i, fcost  > ] == SupDem[ i ];
	   	
};
*/

/*
dvar boolean path[ shard_arcs  ];
dexpr float CCPT_1 = sum( < i, j, fcost > in shard_arcs ) ArcsCost[ i ][ j ] * path[ < i, j, fcost > ] * fcost; 

minimize CCPT_1;

subject to {
		
	// Preserve flows at each node.
	forall( i in shard )	
		ctNodeFlow:		
		 	sum( < i, j, fcost > in shard_arcs ) path[ < i, j, fcost  > ]
	 	 -  sum( < j, i, fcost > in shard_arcs ) path[ < j, i, fcost  > ] == SupDem_shard[ i ];
	   	
};
*/
/*
dvar boolean path[ shard_arcs_1  ];
dexpr float CCPT_1 = sum( < i, j, fcost > in shard_arcs_1 ) ArcsCost[ i ][ j ] * path[ < i, j, fcost > ] * fcost; 

minimize CCPT_1;

subject to {
		
	// Preserve flows at each node.
	forall( i in shard_1 )	
		ctNodeFlow:		
		 	sum( < i, j, fcost > in shard_arcs_1 ) path[ < i, j, fcost  > ]
	 	 -  sum( < j, i, fcost > in shard_arcs_1 ) path[ < j, i, fcost  > ] == SupDem_shard_1[ i ];
	   	
};
*/

/*
dvar boolean path[ shard_arcs_2  ];
dexpr float CCPT_2 = sum( < i, j, fcost > in shard_arcs_2 ) ArcsCost[ i ][ j ] * path[ < i, j, fcost > ] * fcost; 

minimize CCPT_2;

subject to {
		
	// Preserve flows at each node.
	forall( i in shard_2 )	
		ctNodeFlow:		
		 	sum( < i, j, fcost > in shard_arcs_2 ) path[ < i, j, fcost  > ]
	 	 -  sum( < j, i, fcost > in shard_arcs_2 ) path[ < j, i, fcost  > ] == SupDem_shard_2[ i ];
	   	
};
*/

dvar boolean path[ shard_arcs_3  ];
dexpr float CCPT_3 = sum( < i, j, fcost > in shard_arcs_3 ) ArcsCost[ i ][ j ] * path[ < i, j, fcost > ] * fcost; 

minimize CCPT_3;

subject to {
		
	// Preserve flows at each node.
	forall( i in shard_3 )	
		ctNodeFlow:		
		 	sum( < i, j, fcost > in shard_arcs_3 ) path[ < i, j, fcost  > ]
	 	 -  sum( < j, i, fcost > in shard_arcs_3 ) path[ < j, i, fcost  > ] == SupDem_shard_3[ i ];
	   	
};


